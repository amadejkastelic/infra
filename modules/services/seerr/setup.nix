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

  cookieFile = "/run/seerr/cookies.txt";
in

{
  config = lib.mkIf (cfg.enable && jellyfinCfg.enable or false) {
    systemd.services.seerr-setup = {
      description = "Complete Seerr initial setup with Jellyfin";
      after = [
        "seerr.service"
        "jellyfin.service"
        "jellyfin-setup-wizard.service"
        "jellyfin-users.service"
      ];
      requires = [ "seerr.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "seerr";
        RuntimeDirectoryMode = "0755";
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

        BASE_URL="${baseUrl}"

        echo "Waiting for Seerr..."
        for i in {1..60}; do
          if ${pkgs.curl}/bin/curl -sf "$BASE_URL/api/v1/status" >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        STATUS_RESPONSE=$(${pkgs.curl}/bin/curl -s "$BASE_URL/api/v1/settings/public")
        IS_INITIALIZED=$(echo "$STATUS_RESPONSE" | ${pkgs.jq}/bin/jq -r '.initialized // false')

        ${
          if firstAdminUser.password != null then
            ''JELLYFIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/jellyfin-password")''
          else
            ''JELLYFIN_PASSWORD=""''
        }

        if [ "$IS_INITIALIZED" = "true" ]; then
          echo "Seerr already initialized, logging in via Jellyfin..."
          LOGIN_PAYLOAD=$(${pkgs.jq}/bin/jq -n \
            --arg username "${firstAdminName}" \
            --arg password "$JELLYFIN_PASSWORD" \
            '{username: $username, password: $password}')

          LOGIN_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
            -c "${cookieFile}" \
            -H "Content-Type: application/json" \
            -d "$LOGIN_PAYLOAD" \
            -w "\n%{http_code}" \
            "$BASE_URL/api/v1/auth/jellyfin")

          LOGIN_HTTP_CODE=$(echo "$LOGIN_RESPONSE" | tail -n1)

          if [ "$LOGIN_HTTP_CODE" != "200" ] && [ "$LOGIN_HTTP_CODE" != "201" ]; then
            echo "Failed to login (HTTP $LOGIN_HTTP_CODE)" >&2
            echo "$LOGIN_RESPONSE" | head -n-1 >&2
            exit 1
          fi

          echo "Successfully logged in"
          exit 0
        fi

        echo "Running initial setup..."

        SETUP_PAYLOAD=$(${pkgs.jq}/bin/jq -n \
          --arg username "${firstAdminName}" \
          --arg password "$JELLYFIN_PASSWORD" \
          --arg hostname "${cfg.jellyfin.hostname}" \
          --arg port "${toString cfg.jellyfin.port}" \
          --arg useSsl "${lib.boolToString cfg.jellyfin.useSsl}" \
          --arg urlBase "${cfg.jellyfin.urlBase}" \
          --arg email "${firstAdminName}" \
          --arg serverType "${toString cfg.jellyfin.serverType}" \
          '{
            username: $username,
            password: $password,
            hostname: $hostname,
            port: ($port | tonumber),
            useSsl: ($useSsl == "true"),
            urlBase: $urlBase,
            email: $email,
            serverType: ($serverType | tonumber)
          }')

        echo "Connecting to Jellyfin..."
        SETUP_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
          -c "${cookieFile}" \
          -H "Content-Type: application/json" \
          -d "$SETUP_PAYLOAD" \
          -w "\n%{http_code}" \
          "$BASE_URL/api/v1/auth/jellyfin")

        SETUP_HTTP_CODE=$(echo "$SETUP_RESPONSE" | tail -n1)

        if [ "$SETUP_HTTP_CODE" != "200" ] && [ "$SETUP_HTTP_CODE" != "201" ]; then
          echo "Failed to connect to Jellyfin (HTTP $SETUP_HTTP_CODE)" >&2
          echo "$SETUP_RESPONSE" | head -n-1 >&2
          echo "Seerr initial setup failed. You can manually configure Seerr through the web UI." >&2
          exit 0
        fi

        echo "Successfully connected to Jellyfin"

        echo "Syncing Jellyfin libraries..."
        ${pkgs.curl}/bin/curl -sf -X POST \
          -b "${cookieFile}" \
          --max-time 120 \
          "$BASE_URL/api/v1/settings/jellyfin/library/sync" >/dev/null

        LIBRARIES_RESPONSE=$(${pkgs.curl}/bin/curl -sf \
          -b "${cookieFile}" \
          "$BASE_URL/api/v1/settings/jellyfin/library")

        echo "Available libraries:"
        echo "$LIBRARIES_RESPONSE" | ${pkgs.jq}/bin/jq -r '.[] | "\(.id) - \(.name) (\(.type))"'

        LIBRARY_IDS=$(
          echo "$LIBRARIES_RESPONSE" | ${pkgs.jq}/bin/jq -r \
            "${
              if cfg.jellyfin.enableAllLibraries then
                ".[].id"
              else
                ''.[] | select(.type == "movie" or .type == "show") | .id''
            }"
        )

        if [ -n "$LIBRARY_IDS" ]; then
          echo "Enabling libraries: $LIBRARY_IDS"
          for library_id in $LIBRARY_IDS; do
            ${pkgs.curl}/bin/curl -sf -X PUT \
              -b "${cookieFile}" \
              -H "Content-Type: application/json" \
              -d '{"enabled": true}' \
              "$BASE_URL/api/v1/settings/jellyfin/library/$library_id" >/dev/null
          done
          echo "Libraries enabled"
        fi

        echo "Syncing with Jellyfin..."
        SYNC_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
          -b "${cookieFile}" \
          -H "Content-Type: application/json" \
          --max-time 300 \
          -w "\n%{http_code}" \
          "$BASE_URL/api/v1/settings/jellyfin/sync")

        SYNC_HTTP_CODE=$(echo "$SYNC_RESPONSE" | tail -n1)

        if [ "$SYNC_HTTP_CODE" != "200" ] && [ "$SYNC_HTTP_CODE" != "201" ] && [ "$SYNC_HTTP_CODE" != "204" ]; then
          echo "Failed to sync with Jellyfin (HTTP $SYNC_HTTP_CODE)" >&2
          echo "$SYNC_RESPONSE" | head -n-1 >&2
          exit 1
        fi

        echo "Initializing settings..."
        INIT_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
          -b "${cookieFile}" \
          -H "Content-Type: application/json" \
          -w "\n%{http_code}" \
          "$BASE_URL/api/v1/settings/initialize")

        INIT_HTTP_CODE=$(echo "$INIT_RESPONSE" | tail -n1)

        if [ "$INIT_HTTP_CODE" != "200" ] && [ "$INIT_HTTP_CODE" != "201" ] && [ "$INIT_HTTP_CODE" != "204" ]; then
          echo "Failed to initialize settings (HTTP $INIT_HTTP_CODE)" >&2
          echo "$INIT_RESPONSE" | head -n-1 >&2
          exit 1
        fi

        echo "Setting locale..."
        LOCALE_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
          -b "${cookieFile}" \
          -H "Content-Type: application/json" \
          -d '{"locale":"en"}' \
          -w "\n%{http_code}" \
          "$BASE_URL/api/v1/settings/main")

        LOCALE_HTTP_CODE=$(echo "$LOCALE_RESPONSE" | tail -n1)

        if [ "$LOCALE_HTTP_CODE" != "200" ] && [ "$LOCALE_HTTP_CODE" != "201" ] && [ "$LOCALE_HTTP_CODE" != "204" ]; then
          echo "Failed to set locale (HTTP $LOCALE_HTTP_CODE)" >&2
          echo "$LOCALE_RESPONSE" | head -n-1 >&2
          exit 1
        fi

        echo "Seerr setup completed successfully"
      '';
    };
  };
}
