{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seerr;
  jellyfinCfg = config.services.jellyfin;
  baseUrl = "http://127.0.0.1:${toString cfg.port}";

  firstAdminName = "admin";
  firstAdminUser = jellyfinCfg.apiConfig.users.${firstAdminName} or { };

  rulesJson = pkgs.writeText "seerr-router-rules.json" (builtins.toJSON cfg.router.rules);
in

{
  config = lib.mkIf (cfg.enable && cfg.router.enable) {
    systemd.services.seerr-router = {
      description = "Route pending Seerr requests to the correct Sonarr instance";
      after = [
        "seerr.service"
        "seerr-setup.service"
      ];
      wants = [ "seerr-setup.service" ];
      requires = [ "seerr.service" ];

      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "seerr-router";
      }
      // lib.optionalAttrs (firstAdminUser.password != null) {
        LoadCredential = "jellyfin-password:${
          if lib.isAttrs firstAdminUser.password && firstAdminUser.password ? _secret then
            firstAdminUser.password._secret
          else
            pkgs.writeText "jellyfin-password" firstAdminUser.password
        }";
      };

      script = ''
        set -euo pipefail

        BASE_URL="${baseUrl}/api/v1"
        COOKIE_FILE="/run/seerr/cookies.txt"

        for i in {1..30}; do
          if ${pkgs.curl}/bin/curl -sf "${baseUrl}/api/v1/status" >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        code() {
          ${pkgs.curl}/bin/curl -s --max-time 30 \
            -b "$COOKIE_FILE" \
            -H "Content-Type: application/json" \
            -o /dev/null \
            -w '%{http_code}' \
            "$@"
        }

        api() {
          ${pkgs.curl}/bin/curl -s --max-time 30 \
            -b "$COOKIE_FILE" \
            -H "Content-Type: application/json" \
            "$@"
        }

        if [ "$(code "$BASE_URL/settings/sonarr")" != "200" ]; then
          echo "Session cookie missing or expired, logging in via Jellyfin..."
          if [ ! -f "$CREDENTIALS_DIRECTORY/jellyfin-password" ]; then
            echo "No Jellyfin admin password available to authenticate the router" >&2
            exit 1
          fi

          JELLYFIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/jellyfin-password")
          LOGIN_PAYLOAD=$(${pkgs.jq}/bin/jq -n \
            --arg username "${firstAdminName}" \
            --arg password "$JELLYFIN_PASSWORD" \
            '{username: $username, password: $password}')

          LOGIN_HTTP_CODE=$(${pkgs.curl}/bin/curl -s --max-time 30 \
            -c "/run/seerr-router/cookies.txt" \
            -H "Content-Type: application/json" \
            -d "$LOGIN_PAYLOAD" \
            -o /dev/null \
            -w '%{http_code}' \
            "$BASE_URL/auth/jellyfin")

          if [ "$LOGIN_HTTP_CODE" != "200" ] && [ "$LOGIN_HTTP_CODE" != "201" ]; then
            echo "Jellyfin login failed (HTTP $LOGIN_HTTP_CODE)" >&2
            exit 1
          fi

          COOKIE_FILE="/run/seerr-router/cookies.txt"
          echo "Login successful, using fresh session"
        fi

        SONARRS=$(api "$BASE_URL/settings/sonarr")

        UNRESOLVED=$(echo "$SONARRS" | ${pkgs.jq}/bin/jq -r \
          --slurpfile rules "${rulesJson}" \
          --argjson servers "$SONARRS" \
          '$rules[0][] as $rule | select([$servers[] | .name] | index($rule.target) | not) | $rule.target')

        if [ -n "$UNRESOLVED" ]; then
          echo "Router rule targets not found in Seerr Sonarr instances: $UNRESOLVED" >&2
          exit 1
        fi

        RULES=$(echo "$SONARRS" | ${pkgs.jq}/bin/jq -c \
          --slurpfile rules "${rulesJson}" \
          --argjson servers "$SONARRS" \
          '[ $rules[0][] as $rule
             | ($servers[] | select(.name == $rule.target) | .id) as $id
             | {serverId: $id, language: $rule.language, keywordId: $rule.keywordId} ]')

        REQUESTS=$(api "$BASE_URL/request?filter=pending&take=100&skip=0")

        echo "$REQUESTS" | ${pkgs.jq}/bin/jq -r \
          '.results[] | select(.mediaType == "tv" and .media.tmdbId != null) | "\(.id) \(.media.tmdbId) \(.serverId // 0)"' \
          | while read -r request_id tmdb_id current_server; do
              TV=$(api "$BASE_URL/tv/$tmdb_id") || {
                echo "Failed to fetch series metadata for request $request_id (tmdb $tmdb_id), skipping" >&2
                continue
              }

              TARGET=$(echo "$TV" | ${pkgs.jq}/bin/jq -r \
                --argjson rules "$RULES" \
                '. as $tv
                | (($tv.keywords.results // []) + ($tv.keywords.keywords // []) | map(.id)) as $kw
                | [ $rules[]
                    | . as $rule
                    | select(
                        ($rule.keywordId != null and ($kw | index($rule.keywordId)))
                        or ($rule.language != null and (("|" + $rule.language + "|") | contains("|" + ($tv.original_language // "") + "|")))
                      ) ][0].serverId')

              if [ -z "$TARGET" ] || [ "$TARGET" = "null" ] || [ "$TARGET" = "$current_server" ]; then
                continue
              fi

              echo "Routing request $request_id (tmdb $tmdb_id) to Sonarr server $TARGET"
              api -X PUT -o /dev/null -w '%{http_code}' \
                -d "{\"serverId\": $TARGET}" \
                "$BASE_URL/request/$request_id"
              echo
            done

        echo "Seerr request routing completed"
      '';
    };

    systemd.timers.seerr-router = {
      description = "Periodically route pending Seerr requests";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "1min";
      };
    };
  };
}
