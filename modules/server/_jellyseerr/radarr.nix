{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seerr;
  baseUrl = "http://127.0.0.1:${toString cfg.port}";
  cookieFile = "/run/jellyseerr/cookies.txt";

  mkRadarrConfigScript = idx: radarrCfg: ''
    echo "Configuring Radarr instance: ${radarrCfg.name}"

    RADARR_API_KEY=$(cat "$CREDENTIALS_DIRECTORY/radarr-${toString idx}-apikey")

    # Test connection and get profiles
    TEST_PAYLOAD=$(${pkgs.jq}/bin/jq -n \
      --arg hostname "${radarrCfg.hostname}" \
      --arg port "${toString radarrCfg.port}" \
      --arg apiKey "$RADARR_API_KEY" \
      --arg useSsl "${lib.boolToString radarrCfg.useSsl}" \
      --arg baseUrl "${radarrCfg.baseUrl}" \
      '{
        hostname: $hostname,
        port: ($port | tonumber),
        apiKey: $apiKey,
        useSsl: ($useSsl == "true"),
        baseUrl: $baseUrl
      }')

    echo "Testing Radarr connection..."
    TEST_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
      --max-time 30 \
      -b "${cookieFile}" \
      -H "Content-Type: application/json" \
      -d "$TEST_PAYLOAD" \
      -w "\n%{http_code}" \
      "$BASE_URL/api/v1/settings/radarr/test")

    TEST_HTTP_CODE=$(echo "$TEST_RESPONSE" | tail -n1)
    TEST_BODY=$(echo "$TEST_RESPONSE" | sed '$d')

    if [ "$TEST_HTTP_CODE" != "200" ]; then
      echo "Radarr connection test failed (HTTP $TEST_HTTP_CODE)" >&2
      echo "$TEST_BODY" >&2
      exit 1
    fi

    echo "Radarr connection successful"

    # Auto-detect profile ID from profile name
    ${
      if radarrCfg.activeProfileName != null then
        ''
          PROFILE_ID=$(echo "$TEST_BODY" | ${pkgs.jq}/bin/jq -r '.profiles[] | select(.name == "${radarrCfg.activeProfileName}") | .id')
          PROFILE_NAME="${radarrCfg.activeProfileName}"
        ''
      else
        ''
          PROFILE_ID=$(echo "$TEST_BODY" | ${pkgs.jq}/bin/jq -r '.profiles[0].id')
          PROFILE_NAME=$(echo "$TEST_BODY" | ${pkgs.jq}/bin/jq -r '.profiles[0].name')
        ''
    }

    if [ -z "$PROFILE_ID" ] || [ "$PROFILE_ID" = "null" ]; then
      echo "Could not find quality profile${
        if radarrCfg.activeProfileName != null then " '${radarrCfg.activeProfileName}'" else ""
      }" >&2
      echo "Available profiles:" >&2
      echo "$TEST_BODY" | ${pkgs.jq}/bin/jq -r '.profiles[] | " - \(.name)"' >&2
      exit 1
    fi

    echo "Using quality profile: $PROFILE_NAME (ID: $PROFILE_ID)"

    # Check if server already exists
    EXISTING_SERVERS=$(${pkgs.curl}/bin/curl -s \
      --max-time 30 \
      -b "${cookieFile}" \
      "$BASE_URL/api/v1/settings/radarr")

    EXISTING_ID=$(echo "$EXISTING_SERVERS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${radarrCfg.name}") | .id')

    # Build server configuration
    SERVER_CONFIG=$(${pkgs.jq}/bin/jq -n \
      --arg name "${radarrCfg.name}" \
      --arg hostname "${radarrCfg.hostname}" \
      --arg port "${toString radarrCfg.port}" \
      --arg apiKey "$RADARR_API_KEY" \
      --arg useSsl "${lib.boolToString radarrCfg.useSsl}" \
      --arg baseUrl "${radarrCfg.baseUrl}" \
      --arg profileId "$PROFILE_ID" \
      --arg profileName "$PROFILE_NAME" \
      --arg directory "${radarrCfg.activeDirectory}" \
      --arg is4k "${lib.boolToString radarrCfg.is4k}" \
      --arg minimumAvailability "${radarrCfg.minimumAvailability}" \
      --arg isDefault "${lib.boolToString radarrCfg.isDefault}" \
      --arg externalUrl "${radarrCfg.externalUrl}" \
      --arg syncEnabled "${lib.boolToString radarrCfg.syncEnabled}" \
      --arg preventSearch "${lib.boolToString radarrCfg.preventSearch}" \
      '{
        name: $name,
        hostname: $hostname,
        port: ($port | tonumber),
        apiKey: $apiKey,
        useSsl: ($useSsl == "true"),
        baseUrl: $baseUrl,
        activeProfileId: ($profileId | tonumber),
        activeProfileName: $profileName,
        activeDirectory: $directory,
        is4k: ($is4k == "true"),
        minimumAvailability: $minimumAvailability,
        isDefault: ($isDefault == "true"),
        externalUrl: $externalUrl,
        syncEnabled: ($syncEnabled == "true"),
        preventSearch: ($preventSearch == "true")
      }')

    if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
      echo "Updating existing Radarr instance (ID: $EXISTING_ID)..."
      UPDATE_RESPONSE=$(${pkgs.curl}/bin/curl -s -X PUT \
        --max-time 30 \
        -b "${cookieFile}" \
        -H "Content-Type: application/json" \
        -d "$SERVER_CONFIG" \
        -w "\n%{http_code}" \
        "$BASE_URL/api/v1/settings/radarr/$EXISTING_ID")

      UPDATE_HTTP_CODE=$(echo "$UPDATE_RESPONSE" | tail -n1)

      if [ "$UPDATE_HTTP_CODE" != "200" ] && [ "$UPDATE_HTTP_CODE" != "201" ]; then
        echo "Failed to update Radarr instance (HTTP $UPDATE_HTTP_CODE)" >&2
        echo "$UPDATE_RESPONSE" | head -n-1 >&2
        exit 1
      fi

      echo "Radarr instance updated"
    else
      echo "Creating new Radarr instance..."
      CREATE_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
        --max-time 30 \
        -b "${cookieFile}" \
        -H "Content-Type: application/json" \
        -d "$SERVER_CONFIG" \
        -w "\n%{http_code}" \
        "$BASE_URL/api/v1/settings/radarr")

      CREATE_HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)

      if [ "$CREATE_HTTP_CODE" != "200" ] && [ "$CREATE_HTTP_CODE" != "201" ]; then
        echo "Failed to create Radarr instance (HTTP $CREATE_HTTP_CODE)" >&2
        echo "$CREATE_RESPONSE" | head -n-1 >&2
        exit 1
      fi

      echo "Radarr instance created"
    fi
  '';
in

{
  config = lib.mkIf (cfg.enable && cfg.radarr != [ ]) {
    systemd.services.jellyseerr-radarr = {
      description = "Configure Jellyseerr Radarr integration";
      after = [
        "jellyseerr-setup.service"
        "jellyseerr-sonarr.service"
      ];
      requires = [ "jellyseerr-setup.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Group = "jellyseerr";
        LoadCredential = lib.imap0 (idx: r: "radarr-${toString idx}-apikey:${r.apiKeyPath}") cfg.radarr;
      };

      script = ''
        set -euo pipefail

        BASE_URL="${baseUrl}"

        # Wait for Jellyseerr to be ready
        for i in {1..60}; do
          if ${pkgs.curl}/bin/curl -sf "$BASE_URL/api/v1/status" >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        # Configure each Radarr instance
        ${lib.concatStringsSep "\n" (lib.imap0 (idx: r: mkRadarrConfigScript idx r) cfg.radarr)}

        # Delete servers not in configuration
        CONFIGURED_NAMES="${
          pkgs.writeText "radarr-names.json" (builtins.toJSON (map (r: r.name) cfg.radarr))
        }"

        EXISTING_SERVERS=$(${pkgs.curl}/bin/curl -s \
          --max-time 30 \
          -b "${cookieFile}" \
          "$BASE_URL/api/v1/settings/radarr")

        SERVERS_TO_DELETE=$(echo "$EXISTING_SERVERS" | ${pkgs.jq}/bin/jq -r \
          --slurpfile configured "$CONFIGURED_NAMES" \
          '.[] | select([.name] | inside($configured[0]) | not) | .id')

        for server_id in $SERVERS_TO_DELETE; do
          echo "Deleting Radarr server (ID: $server_id)..."
          ${pkgs.curl}/bin/curl -sf -X DELETE \
            --max-time 30 \
            -b "${cookieFile}" \
            "$BASE_URL/api/v1/settings/radarr/$server_id" >/dev/null
        done

        echo "Radarr configuration completed"
      '';
    };
  };
}
