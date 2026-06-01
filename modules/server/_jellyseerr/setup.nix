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

  # Use admin as the admin user for Jellyseerr setup
  firstAdminName = "admin";
  firstAdminUser = jellyfinCfg.apiConfig.users.${firstAdminName} or { };

  # Cookie file for authentication
  cookieFile = "/run/jellyseerr/cookies.txt";

  # Auth script to source for authenticated requests
  authScript = pkgs.writeText "jellyseerr-auth.sh" ''
    # Wait for Jellyseerr to be ready
    for i in {1..60}; do
      if ${pkgs.curl}/bin/curl -sf "${baseUrl}/api/v1/status" >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done

    # Check if we need to authenticate
    if [ ! -f "${cookieFile}" ]; then
      echo "Cookie file not found, authentication may be required"
    fi
  '';
in

{
  config = lib.mkIf (cfg.enable && jellyfinCfg.enable or false) {
    systemd.services.jellyseerr-setup = {
      description = "Complete Jellyseerr initial setup with Jellyfin";
      after = [
        "jellyseerr.service"
        "jellyfin.service"
        "jellyfin-setup-wizard.service"
        "jellyfin-users.service"
      ];
      requires = [ "jellyseerr.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "jellyseerr";
        RuntimeDirectoryMode = "0755";
        User = "jellyseerr";
        Group = "jellyseerr";
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

        # Wait for Jellyseerr
        echo "Waiting for Jellyseerr..."
        for i in {1..60}; do
          if ${pkgs.curl}/bin/curl -sf "$BASE_URL/api/v1/status" >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        # Check if already initialized
        STATUS_RESPONSE=$(${pkgs.curl}/bin/curl -s "$BASE_URL/api/v1/settings/public")
        IS_INITIALIZED=$(echo "$STATUS_RESPONSE" | ${pkgs.jq}/bin/jq -r '.initialized // false')

        # Prepare credentials
        ${
          if firstAdminUser.password != null then
            ''JELLYFIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/jellyfin-password")''
          else
            ''JELLYFIN_PASSWORD=""''
        }

        if [ "$IS_INITIALIZED" = "true" ]; then
          echo "Jellyseerr already initialized, logging in via Jellyfin..."
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

        # Initial setup - connect to Jellyfin
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
          echo "Jellyseerr initial setup failed. You can manually configure Jellyseerr through the web UI." >&2
          exit 0
        fi

        echo "Successfully connected to Jellyfin"

        # Step 2: Fetch and enable libraries
        echo "Fetching library list from Jellyfin..."
        LIBRARIES_RESPONSE=$(${pkgs.curl}/bin/curl -sf \
          -b "${cookieFile}" \
          "$BASE_URL/api/v1/settings/jellyfin/library?sync=true")

        echo "Available libraries:"
        echo "$LIBRARIES_RESPONSE" | ${pkgs.jq}/bin/jq -r '.[] | "\(.id) - \(.name) (\(.type))"'

        # Enable all libraries or filter by type
        ${
          if cfg.jellyfin.enableAllLibraries then
            ''
              LIBRARY_IDS=$(echo "$LIBRARIES_RESPONSE" | ${pkgs.jq}/bin/jq -r '.[].id' | paste -sd,)
            ''
          else
            ''
              LIBRARY_IDS=$(echo "$LIBRARIES_RESPONSE" | ${pkgs.jq}/bin/jq -r '.[] | select(.type == "movies" or .type == "tvshows") | .id' | paste -sd,)
            ''
        }

        if [ -n "$LIBRARY_IDS" ]; then
          echo "Enabling libraries: $LIBRARY_IDS"
          ${pkgs.curl}/bin/curl -sf \
            -b "${cookieFile}" \
            "$BASE_URL/api/v1/settings/jellyfin/library?enable=$LIBRARY_IDS" >/dev/null
          echo "Libraries enabled"
        fi

        # Step 3: Complete initialization
        echo "Syncing with Jellyfin..."
        SYNC_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
          -b "${cookieFile}" \
          -H "Content-Type: application/json" \
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

        echo "Jellyseerr setup completed successfully"
      '';
    };
  };
}
