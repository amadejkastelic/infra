{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jellyfin;

  baseUrl =
    if cfg.apiConfig.baseUrl == "" then
      "http://127.0.0.1:${toString cfg.apiConfig.port}"
    else
      "http://127.0.0.1:${toString cfg.apiConfig.port}/${cfg.apiConfig.baseUrl}";

  adminUsers = lib.filterAttrs (_: user: user.policy.isAdministrator or false) cfg.apiConfig.users;
  sortedAdminNames = builtins.sort builtins.lessThan (lib.attrNames adminUsers);
  firstAdminName = if sortedAdminNames != [ ] then builtins.head sortedAdminNames else null;
  firstAdminUser = if firstAdminName != null then adminUsers.${firstAdminName} else null;

  waitForApi =
    {
      timeout ? 180,
    }:
    ''
      for attempt in {1..${toString timeout}}; do
        HTTP_CODE=$(${pkgs.curl}/bin/curl --connect-timeout 5 --max-time 10 -s -o /dev/null -w "%{http_code}" "$BASE_URL/System/Info/Public" 2>/dev/null || echo "000")

        if [ "$HTTP_CODE" = "200" ]; then
          break
        fi

        if [ $attempt -eq ${toString timeout} ]; then
          echo "ERROR: Jellyfin API did not become ready after ${toString timeout} attempts" >&2
          exit 1
        fi

        sleep 1
      done
    '';

  mkWaitForApiService =
    {
      description ? "Wait for Jellyfin API to be ready",
      timeout ? 180,
    }:
    {
      description = description;
      after = [ "jellyfin.service" ];
      bindsTo = [ "jellyfin.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -eu

        BASE_URL="${baseUrl}"

        ${waitForApi { inherit timeout; }}
      '';
    };

  mkSetupWizardService =
    {
      description ? "Complete Jellyfin setup wizard",
    }:
    let
      adminPasswordVal = firstAdminUser.password or "";
      adminPasswordSecret = adminPasswordVal._secret or null;
      adminPasswordPlain = if adminPasswordSecret == null then adminPasswordVal else null;
    in
    {
      description = description;
      after = [
        "jellyfin.service"
        "jellyfin-wait-api.service"
      ];
      bindsTo = [ "jellyfin.service" ];
      requires = [ "jellyfin-wait-api.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = lib.optional (adminPasswordSecret != null) "admin_password:${adminPasswordSecret}";
      };

      script = ''
        set -eu

        BASE_URL="${baseUrl}"
        SERVER_NAME="${config.networking.hostName}"

        ${waitForApi { }}

        ADMIN_PASSWORD=""
        ${lib.optionalString (adminPasswordPlain != null) ''ADMIN_PASSWORD="${adminPasswordPlain}"''}

        if [ -f "$CREDENTIALS_DIRECTORY/admin_password" ]; then
          ADMIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/admin_password")
        fi

        SYSTEM_INFO=""
        for attempt in {1..20}; do
          SYSTEM_INFO=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" "$BASE_URL/System/Info/Public" 2>/dev/null || printf '\n000\n')

          HTTP_CODE=$(echo "$SYSTEM_INFO" | tail -n1)

          if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
            SYSTEM_INFO=$(echo "$SYSTEM_INFO" | sed '$d')
            break
          fi

          if [[ $attempt -eq 20 ]]; then
            echo "ERROR: Failed to fetch system info after 20 attempts (HTTP $HTTP_CODE)" >&2
            exit 1
          fi

          sleep 1
        done

        STARTUP_WIZARD_COMPLETED=$(echo "$SYSTEM_INFO" | ${pkgs.jq}/bin/jq -r '.StartupWizardCompleted // true' 2>/dev/null || echo "true")

        if [ "$STARTUP_WIZARD_COMPLETED" = "false" ]; then
          BACKOFF=1
          for attempt in {1..20}; do
            RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
              -H "Content-Type: application/json" \
              -d '{"ServerName":"'"$SERVER_NAME"'","UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' \
              -w "\n%{http_code}" \
              "$BASE_URL/Startup/Configuration" 2>/dev/null || printf '\n000\n')

            HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

            if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
              break
            fi

            if [[ $attempt -eq 20 ]]; then
              echo "ERROR: Failed to set configuration after 20 attempts (HTTP $HTTP_CODE)" >&2
              exit 1
            fi

            sleep $BACKOFF
            BACKOFF=$((BACKOFF * 2))
            if [ $BACKOFF -gt 8 ]; then
              BACKOFF=8
            fi
          done

          BACKOFF=1
          for attempt in {1..20}; do
            RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
              -H "Content-Type: application/json" \
              -d '{"Name": "'"${firstAdminName}"'", "Password": "'"$ADMIN_PASSWORD"'"}' \
              -w "\n%{http_code}" \
              "$BASE_URL/Startup/User" 2>/dev/null || printf '\n000\n')

          HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

          if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
            break
          fi

          if [[ $attempt -eq 20 ]]; then
            echo "ERROR: Failed to create first user ${firstAdminName} after 20 attempts (HTTP $HTTP_CODE)" >&2
            exit 1
          fi

          sleep $BACKOFF
          BACKOFF=$((BACKOFF * 2))
          if [ $BACKOFF -gt 8 ]; then
            BACKOFF=8
          fi
        done

          BACKOFF=1
          for attempt in {1..20}; do
            RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
              -H "Content-Type: application/json" \
              -d '{"EnableRemoteAccess":true}' \
              -w "\n%{http_code}" \
              "$BASE_URL/Startup/RemoteAccess" 2>/dev/null || printf '\n000\n')

            HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

            if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
              break
            fi

            if [[ $attempt -eq 20 ]]; then
              echo "ERROR: Failed to configure remote access after 20 attempts (HTTP $HTTP_CODE)" >&2
              exit 1
            fi

            sleep $BACKOFF
            BACKOFF=$((BACKOFF * 2))
            if [ $BACKOFF -gt 8 ]; then
              BACKOFF=8
            fi
          done

          BACKOFF=1
          for attempt in {1..20}; do
            RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
              -w "\n%{http_code}" \
              "$BASE_URL/Startup/Complete" 2>/dev/null || printf '\n000\n')

            HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

            if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
              break
            fi

            if [[ $attempt -eq 20 ]]; then
              echo "ERROR: Failed to complete setup wizard after 20 attempts (HTTP $HTTP_CODE)" >&2
              exit 1
            fi

            sleep $BACKOFF
            BACKOFF=$((BACKOFF * 2))
            if [ $BACKOFF -gt 8 ]; then
              BACKOFF=8
            fi
          done
        fi
      '';
    };

  mkAuthService =
    {
      description ? "Authenticate with Jellyfin and cache token",
    }:
    let
      adminPasswordVal = firstAdminUser.password or "";
      adminPasswordSecret = adminPasswordVal._secret or null;
      adminPasswordPlain = if adminPasswordSecret == null then adminPasswordVal else null;
    in
    {
      description = description;
      after = [
        "jellyfin.service"
        "jellyfin-setup-wizard.service"
      ];
      bindsTo = [ "jellyfin.service" ];
      requires = [ "jellyfin-setup-wizard.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = lib.optional (adminPasswordSecret != null) "admin_password:${adminPasswordSecret}";
      };

      script = ''
        set -eu

        BASE_URL="${baseUrl}"
        TOKEN_FILE="/run/jellyfin/auth-token"

        ${waitForApi { }}

        ADMIN_PASSWORD=""
        ${lib.optionalString (adminPasswordPlain != null) ''ADMIN_PASSWORD="${adminPasswordPlain}"''}

        if [ -f "$CREDENTIALS_DIRECTORY/admin_password" ]; then
          ADMIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/admin_password")
        fi

        ACCESS_TOKEN=""
        BACKOFF=1
        for attempt in {1..10}; do
          AUTH_RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
            -H "Content-Type: application/json" \
            -H 'Authorization: MediaBrowser Client="jellyfin-nixos", Device="NixOS", DeviceId="jellyfin-nixos", Version="1.0.0"' \
            -d '{"Username": "'"${firstAdminName}"'", "Pw": "'"$ADMIN_PASSWORD"'"}' \
            "$BASE_URL/Users/AuthenticateByName" 2>/dev/null || echo "")

          ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | ${pkgs.jq}/bin/jq -r '.AccessToken // empty' 2>/dev/null || echo "")

          if [ -n "$ACCESS_TOKEN" ]; then
            break
          fi

          if [[ $attempt -eq 10 ]]; then
            echo "ERROR: Failed to authenticate as ${firstAdminName} after 10 attempts" >&2
            echo "Last auth response: $AUTH_RESPONSE" >&2
            exit 1
          fi

          sleep $BACKOFF
          BACKOFF=$((BACKOFF * 2))
          if [ $BACKOFF -gt 8 ]; then
            BACKOFF=8
          fi
        done

        mkdir -p "$(dirname "$TOKEN_FILE")"
        echo -n "$ACCESS_TOKEN" > "$TOKEN_FILE"
        ${pkgs.coreutils}/bin/chmod 600 "$TOKEN_FILE"
      '';
    };

  mkLibrariesService =
    {
      description ? "Configure Jellyfin libraries via API",
    }:
    let
      libraries = cfg.apiConfig.libraries;
      libraryNames = lib.attrNames libraries;
      configuredNamesJSON = builtins.toJSON libraryNames;
    in
    {
      description = description;
      after = [
        "jellyfin.service"
        "jellyfin-auth.service"
      ];
      bindsTo = [ "jellyfin.service" ];
      requires = [ "jellyfin-auth.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
          set -eu

          BASE_URL="${baseUrl}"
          CONFIGURED_NAMES='${configuredNamesJSON}'

          ${waitForApi { }}

          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              _: libCfg:
              lib.concatMapStringsSep "\n" (path: ''
                mkdir -p "${path}"
              '') libCfg.paths
            ) libraries
          )}

          ACCESS_TOKEN=$(cat /run/jellyfin/auth-token)
          export AUTH_HEADER='Authorization: MediaBrowser Client="jellyfin-nixos", Device="NixOS", DeviceId="jellyfin-nixos", Version="1.0.0", Token="'"$ACCESS_TOKEN"'"'

          LIBRARIES_RESPONSE=""
          BACKOFF=1
          for attempt in {1..20}; do
            LIBRARIES_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" \
              -H "$AUTH_HEADER" \
              "$BASE_URL/Library/VirtualFolders" 2>/dev/null || printf '\n000\n')

            LIBRARIES_HTTP_CODE=$(echo "$LIBRARIES_RESPONSE" | tail -n1)

            if [ "$LIBRARIES_HTTP_CODE" -ge 200 ] && [ "$LIBRARIES_HTTP_CODE" -lt 300 ]; then
              break
            fi

            if [[ $attempt -eq 20 ]]; then
              echo "ERROR: Failed to fetch libraries from Jellyfin API (HTTP $LIBRARIES_HTTP_CODE)" >&2
              exit 1
            fi

            sleep $BACKOFF
            BACKOFF=$((BACKOFF * 2))
            if [ $BACKOFF -gt 8 ]; then
              BACKOFF=8
            fi
          done

          LIBRARIES_JSON=$(echo "$LIBRARIES_RESPONSE" | sed '$d')

          echo "$LIBRARIES_JSON" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r library; do
            LIBRARY_NAME=$(echo "$library" | ${pkgs.jq}/bin/jq -r '.Name')

            if ! echo "$CONFIGURED_NAMES" | ${pkgs.jq}/bin/jq -e --arg name "$LIBRARY_NAME" 'index($name)' >/dev/null 2>&1; then
              DELETE_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" -X DELETE \
                -H "$AUTH_HEADER" \
                "$BASE_URL/Library/VirtualFolders?name=$(${pkgs.jq}/bin/jq -rn --arg n "$LIBRARY_NAME" '$n|@uri')" 2>/dev/null || printf '\n000\n')

              DELETE_HTTP_CODE=$(echo "$DELETE_RESPONSE" | tail -n1)

              if [ "$DELETE_HTTP_CODE" -lt 200 ] || [ "$DELETE_HTTP_CODE" -ge 300 ]; then
                echo "WARNING: Failed to delete library $LIBRARY_NAME (HTTP $DELETE_HTTP_CODE)" >&2
              fi
            fi
        done

        LIBRARIES_JSON=$(${pkgs.curl}/bin/curl -s \
          -H "$AUTH_HEADER" \
          "$BASE_URL/Library/VirtualFolders" 2>/dev/null || echo "[]")

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (libraryName: libCfg: ''
            EXISTING_LIBRARY=$(echo "$LIBRARIES_JSON" | ${pkgs.jq}/bin/jq -r --arg name "${libraryName}" '.[] | select(.Name == $name) // empty')

            if [ -z "$EXISTING_LIBRARY" ]; then
              ${lib.concatMapStringsSep "\n" (path: ''
                mkdir -p "${path}"
              '') libCfg.paths}

              PAYLOAD=$(${pkgs.jq}/bin/jq -n \
                --argjson paths '${builtins.toJSON libCfg.paths}' \
                '{LibraryOptions: {PathInfos: ($paths | map({Path: .}))}}')

              CREATE_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" -X POST \
                -H "$AUTH_HEADER" \
                -H "Content-Type: application/json" \
                -d "$PAYLOAD" \
                "$BASE_URL/Library/VirtualFolders?name=$(${pkgs.jq}/bin/jq -rn --arg n "${libraryName}" '$n|@uri')&collectionType=${libCfg.collectionType}&refreshLibrary=true")

              CREATE_HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)

              if [ "$CREATE_HTTP_CODE" -lt 200 ] || [ "$CREATE_HTTP_CODE" -ge 300 ]; then
                echo "ERROR: Failed to create library ${libraryName} (HTTP $CREATE_HTTP_CODE)" >&2
                exit 1
              fi
            fi
          '') libraries
        )}
      '';
    };

  mkUserService =
    {
      description ? "Configure Jellyfin users via API",
    }:
    let
      users = cfg.apiConfig.users;
      usersWithSecrets = lib.filterAttrs (
        _: userCfg: (userCfg.password or { })._secret or null != null
      ) users;
      loadCredentials = map (
        userName: "user_password_${userName}:${users.${userName}.password._secret}"
      ) (lib.attrNames usersWithSecrets);
    in
    {
      description = description;
      after = [
        "jellyfin.service"
        "jellyfin-libraries.service"
      ];
      bindsTo = [ "jellyfin.service" ];
      requires = [ "jellyfin-libraries.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = loadCredentials;
      };

      script = ''
        set -eu

        BASE_URL="${baseUrl}"

        ${waitForApi { }}

        ACCESS_TOKEN=$(cat /run/jellyfin/auth-token)
        export AUTH_HEADER='Authorization: MediaBrowser Client="jellyfin-nixos", Device="NixOS", DeviceId="jellyfin-nixos", Version="1.0.0", Token="'"$ACCESS_TOKEN"'"'

        USERS_RESPONSE=""
        BACKOFF=1
        for attempt in {1..20}; do
          USERS_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" -H "$AUTH_HEADER" "$BASE_URL/Users" 2>/dev/null || printf '\n000\n')

          USERS_HTTP_CODE=$(echo "$USERS_RESPONSE" | tail -n1)

          if [ "$USERS_HTTP_CODE" -ge 200 ] && [ "$USERS_HTTP_CODE" -lt 300 ]; then
            break
          fi

          if [[ $attempt -eq 20 ]]; then
            echo "ERROR: Failed to fetch users from Jellyfin API (HTTP $USERS_HTTP_CODE)" >&2
            exit 1
          fi

          sleep $BACKOFF
          BACKOFF=$((BACKOFF * 2))
          if [ $BACKOFF -gt 8 ]; then
            BACKOFF=8
          fi
        done

        USERS_JSON=$(echo "$USERS_RESPONSE" | sed '$d')

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (userName: userCfg: ''
            USER_ID=$(echo "$USERS_JSON" | ${pkgs.jq}/bin/jq -r '.[] | select(.Name == "${userName}") | .Id' || echo "")

            if [ -z "$USER_ID" ]; then
              USER_PASSWORD=""

              if [ -f "$CREDENTIALS_DIRECTORY/user_password_${userName}" ]; then
                USER_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/user_password_${userName}")
              fi

              RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST \
                -H "$AUTH_HEADER" \
                -H "Content-Type: application/json" \
                -d '{"Name": "'"${userName}"'", "Password": "'"$USER_PASSWORD"'"}' \
                -w "\n%{http_code}" \
                "$BASE_URL/Users/New" 2>/dev/null || printf '\n000\n')

              HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

              if [ "$HTTP_CODE" -lt 200 ] || [ "$HTTP_CODE" -ge 300 ]; then
                echo "ERROR: Failed to create user ${userName} (HTTP $HTTP_CODE)" >&2
                exit 1
              fi

              USERS_JSON=$(${pkgs.curl}/bin/curl -s -H "$AUTH_HEADER" "$BASE_URL/Users" 2>/dev/null || echo "[]")
              USER_ID=$(echo "$USERS_JSON" | ${pkgs.jq}/bin/jq -r '.[] | select(.Name == "${userName}") | .Id')
            fi
          '') users
        )}
      '';
    };
  mkApiKeysService =
    {
      description ? "Create Jellyfin API keys",
    }:
    let
      apiKeys = cfg.apiConfig.apiKeys;
      slug = name: lib.toLower (lib.replaceStrings [ " " ] [ "-" ] name);
    in
    {
      description = description;
      after = [
        "jellyfin.service"
        "jellyfin-auth.service"
      ];
      bindsTo = [ "jellyfin.service" ];
      requires = [ "jellyfin-auth.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -eu

        BASE_URL="${baseUrl}"

        ${waitForApi { }}

        ACCESS_TOKEN=$(cat /run/jellyfin/auth-token)
        export AUTH_HEADER='Authorization: MediaBrowser Client="jellyfin-nixos", Device="NixOS", DeviceId="jellyfin-nixos", Version="1.0.0", Token="'"$ACCESS_TOKEN"'"'

        mkdir -p /run/jellyfin/api-keys

        KEYS_JSON=$(${pkgs.curl}/bin/curl -sf -H "$AUTH_HEADER" "$BASE_URL/Auth/Keys" 2>/dev/null || echo "[]")

        ${lib.concatMapStringsSep "\n" (name: ''
          KEY_NAME="${name}"
          KEY_SLUG="${slug name}"
          KEY_FILE="/run/jellyfin/api-keys/$KEY_SLUG.txt"

          TOKEN=$(echo "$KEYS_JSON" | ${pkgs.jq}/bin/jq -r --arg n "$KEY_NAME" '(.Items // .)[] | select(.AppName == $n) | .AccessToken' || echo "")

          if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
            echo "API key '$KEY_NAME' not found, creating"
            ${pkgs.curl}/bin/curl -sSf -X POST -H "$AUTH_HEADER" \
              "$BASE_URL/Auth/Keys?app=$(${pkgs.jq}/bin/jq -rn --arg n "$KEY_NAME" '$n|@uri')" || true

            KEYS_JSON=$(${pkgs.curl}/bin/curl -sf -H "$AUTH_HEADER" "$BASE_URL/Auth/Keys" 2>/dev/null || echo "[]")
            TOKEN=$(echo "$KEYS_JSON" | ${pkgs.jq}/bin/jq -r --arg n "$KEY_NAME" '(.Items // .)[] | select(.AppName == $n) | .AccessToken' || echo "")

            if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
              echo "ERROR: Failed to create API key '$KEY_NAME'" >&2
              exit 1
            fi
          fi

          echo -n "$TOKEN" > "$KEY_FILE"
          chmod 600 "$KEY_FILE"
        '') apiKeys}
      '';
    };
in
{
  inherit
    mkWaitForApiService
    mkSetupWizardService
    mkAuthService
    mkLibrariesService
    mkUserService
    mkApiKeysService
    ;
}
