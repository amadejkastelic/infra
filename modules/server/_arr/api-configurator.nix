{
  lib,
  pkgs,
  config,
}:
let
  mkHostConfigService =
    serviceName: serviceConfig:
    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} host via API";
      after = [ "${serviceName}.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "api_key:${serviceConfig.apiKeyPath}"
        ]
        ++ lib.optional (
          serviceConfig.hostConfig.passwordPath != null
        ) "auth_password:${serviceConfig.hostConfig.passwordPath}";
        ExecStartPre = import ./wait-for-api.nix {
          inherit
            lib
            pkgs
            serviceName
            serviceConfig
            ;
        };
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        ${lib.optionalString (
          serviceConfig.hostConfig.passwordPath != null
        ) "AUTH_PASSWORD=$(cat $CREDENTIALS_DIRECTORY/auth_password)"}

        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching current host configuration..."
        HOST_CONFIG=$(${pkgs.curl}/bin/curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/config/host" 2>&1)
        CURL_EXIT=$?

        if [ $CURL_EXIT -ne 0 ]; then
          echo "Failed to fetch host configuration (curl exit code: $CURL_EXIT): $HOST_CONFIG"
          exit 1
        fi

        if [ -z "$HOST_CONFIG" ]; then
          echo "Failed to fetch host configuration (empty response)"
          exit 1
        fi

        echo "Host config response: $HOST_CONFIG"

        CONFIG_ID=$(echo "$HOST_CONFIG" | ${pkgs.jq}/bin/jq -r '.id' 2>&1)
        JQ_EXIT=$?

        if [ $JQ_EXIT -ne 0 ]; then
          echo "Failed to parse config ID from host config: $CONFIG_ID"
          exit 1
        fi

        echo "Building configuration..."
        NEW_CONFIG=$(echo "$HOST_CONFIG" | ${pkgs.jq}/bin/jq \
          --arg apiKey "$API_KEY" \
          ${
            lib.optionalString (
              serviceConfig.hostConfig.passwordPath != null
            ) "--arg password \"$AUTH_PASSWORD\""
          } \
          --argjson port "${builtins.toString serviceConfig.hostConfig.port}" \
          --arg urlBase "${serviceConfig.hostConfig.urlBase}" \
          --arg instanceName "${serviceConfig.hostConfig.instanceName}" \
          --arg logLevel "info" \
          --argjson launchBrowser false \
          --argjson analyticsEnabled false \
          --arg authenticationMethod "External" \
          --arg authenticationRequired "DisabledForLocalAddresses" \
          '{
            port: $port,
            urlBase: $urlBase,
            instanceName: $instanceName,
            apiKey: $apiKey,
            ${lib.optionalString (serviceConfig.hostConfig.passwordPath != null) ''
              password: $password,
              passwordConfirmation: $password,''}
            launchBrowser: $launchBrowser,
            analyticsEnabled: $analyticsEnabled,
            authenticationMethod: $authenticationMethod,
            authenticationRequired: $authenticationRequired,
            logLevel: $logLevel
          } as $updates
          | . * $updates')

        echo "Updating ${capitalizedName} configuration via API..."
        UPDATE_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" -X PUT \
          -H "X-Api-Key: $API_KEY" \
          -H "Content-Type: application/json" \
          -d "$NEW_CONFIG" \
          "$BASE_URL/config/host/$CONFIG_ID")

        HTTP_CODE=$(echo "$UPDATE_RESPONSE" | tail -n1)

        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
          echo "Configuration updated successfully (HTTP $HTTP_CODE)"

          echo "Restarting ${capitalizedName} service..."
          systemctl restart ${serviceName}.service
          echo "${capitalizedName} service restarted"
        else
          echo "Failed to update configuration (HTTP $HTTP_CODE)"
          echo "Response: $(echo "$UPDATE_RESPONSE" | head -n -1)"
          exit 1
        fi
      '';
    };

  mkRootFoldersService =
    serviceName: serviceConfig:
    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} root folders via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [ "api_key:${serviceConfig.apiKeyPath}" ];
        ExecStartPre = import ./wait-for-api.nix {
          inherit
            lib
            pkgs
            serviceName
            serviceConfig
            ;
        };
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching existing root folders..."
        ROOT_FOLDERS=$(${pkgs.curl}/bin/curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/rootfolder")

        CONFIGURED_PATHS=$(cat <<'EOF'
        ${builtins.toJSON (map (f: f.path) serviceConfig.rootFolders)}
        EOF
        )

        echo "Removing root folders not in configuration..."
        echo "$ROOT_FOLDERS" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r folder; do
          FOLDER_PATH=$(echo "$folder" | ${pkgs.jq}/bin/jq -r '.path')
          if ! echo "$CONFIGURED_PATHS" | ${pkgs.jq}/bin/jq -e --arg path "$FOLDER_PATH" 'index($path)' >/dev/null 2>&1; then
            FOLDER_ID=$(echo "$folder" | ${pkgs.jq}/bin/jq -r '.id')
            echo "Deleting root folder not in config: $FOLDER_PATH (ID: $FOLDER_ID)"
            ${pkgs.curl}/bin/curl -sSf -X DELETE \
              -H "X-Api-Key: $API_KEY" \
              "$BASE_URL/rootfolder/$FOLDER_ID" >/dev/null || echo "Warning: Failed to delete root folder $FOLDER_PATH"
          fi
        done

        echo "Creating root folders..."
        ${lib.concatMapStringsSep "\n" (folder: ''
          echo "Processing root folder: ${folder.path}"

          EXISTING_FOLDER=$(echo "$ROOT_FOLDERS" | ${pkgs.jq}/bin/jq -r '.[] | select(.path == "${folder.path}") | @json' || echo "")

          if [ -n "$EXISTING_FOLDER" ]; then
            echo "Root folder ${folder.path} already exists"
          else
            NEW_FOLDER=$(${pkgs.jq}/bin/jq -n \
              --arg path "${folder.path}" \
              '{path: $path}')

            ${pkgs.curl}/bin/curl -sSf -X POST \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$NEW_FOLDER" \
              "$BASE_URL/rootfolder" >/dev/null

            echo "Root folder ${folder.path} created"
          fi
        '') serviceConfig.rootFolders}

        echo "${capitalizedName} root folders configuration complete"
      '';
    };

  mkDownloadClientsService =
    serviceName: serviceConfig:
    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
      arrType = builtins.elemAt (lib.splitString "-" serviceName) 0;
      categoryField =
        if arrType == "radarr" then
          "movieCategory"
        else if lib.hasPrefix "sonarr" serviceName then
          "tvCategory"
        else if arrType == "lidarr" then
          "musicCategory"
        else
          "category";
    in
    {
      description = "Configure ${capitalizedName} download clients via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "api_key:${serviceConfig.apiKeyPath}"
        ]
        ++ map (
          c: "client_api_${lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower c.name)}:${c.apiKeyPath}"
        ) serviceConfig.downloadClients;
        ExecStartPre = import ./wait-for-api.nix {
          inherit
            lib
            pkgs
            serviceName
            serviceConfig
            ;
        };
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching download client schemas..."
        SCHEMAS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/downloadclient/schema")

        echo "Fetching existing download clients..."
        DOWNLOAD_CLIENTS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/downloadclient")

        CONFIGURED_NAMES=$(cat <<'EOF'
        ${builtins.toJSON (map (d: d.name) serviceConfig.downloadClients)}
        EOF
        )

        echo "Removing download clients not in configuration..."
        echo "$DOWNLOAD_CLIENTS" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r downloadClient; do
          CLIENT_NAME=$(echo "$downloadClient" | ${pkgs.jq}/bin/jq -r '.name')
          CLIENT_ID=$(echo "$downloadClient" | ${pkgs.jq}/bin/jq -r '.id')

          if ! echo "$CONFIGURED_NAMES" | ${pkgs.jq}/bin/jq -e --arg name "$CLIENT_NAME" 'index($name)' >/dev/null 2>&1; then
            echo "Deleting download client not in config: $CLIENT_NAME (ID: $CLIENT_ID)"
            ${pkgs.curl}/bin/curl -sSf -X DELETE \
              -H "X-Api-Key: $API_KEY" \
              "$BASE_URL/downloadclient/$CLIENT_ID" >/dev/null || echo "Warning: Failed to delete download client $CLIENT_NAME"
          fi
        done

        ${lib.concatMapStringsSep "\n" (clientConfig: ''
          echo "Processing download client: ${clientConfig.name}"

          CLIENT_API_KEY=$(cat $CREDENTIALS_DIRECTORY/client_api_${
            lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower clientConfig.name)
          })

          ALL_OVERRIDES=$(${pkgs.jq}/bin/jq -n \
            --arg host "${clientConfig.host or "127.0.0.1"}" \
            --arg port "${toString (clientConfig.port or 8080)}" \
            --arg importMode "${clientConfig.importMode or "copy"}" \
            '{host: $host, port: ($port | tonumber), importMode: $importMode}')
          echo "ALL_OVERRIDES: $ALL_OVERRIDES"
          echo "DOWNLOAD_CLIENTS: $DOWNLOAD_CLIENTS"
          FIELD_OVERRIDES=$(${pkgs.jq}/bin/jq -n --argjson all "$ALL_OVERRIDES" --arg cat "${
            clientConfig.category or "movies"
          }" '$all + {${categoryField}: $cat} | with_entries(select(.key | startswith("_") | not))')

          echo "DOWNLOAD_CLIENTS: $DOWNLOAD_CLIENTS"
          EXISTING_CLIENT=$(echo "$DOWNLOAD_CLIENTS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${clientConfig.name}") | @json' || echo "")

          if [ -n "$EXISTING_CLIENT" ]; then
            echo "Download client ${clientConfig.name} already exists, updating..."
            CLIENT_ID=$(echo "$EXISTING_CLIENT" | ${pkgs.jq}/bin/jq -r '.id')

            UPDATED_CLIENT=$(${pkgs.jq}/bin/jq -n \
              --arg apiKey "$CLIENT_API_KEY" \
              --argjson overrides "$FIELD_OVERRIDES" \
              --argjson existing "$EXISTING_CLIENT" \
              '$existing |
                .enable = true |
                .priority = 1 |
                .fields |= map(
                  if .name == "apiKey" then .value = $apiKey
                  elif (.name | IN($overrides | keys[])) then .value = $overrides[.name]
                  else .
                  end
                )')

            echo "Updating download client with payload:"
            echo "$UPDATED_CLIENT"

            ${pkgs.curl}/bin/curl -sSf -X PUT \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$UPDATED_CLIENT" \
              "$BASE_URL/downloadclient/$CLIENT_ID"

            echo "Download client ${clientConfig.name} updated"
          else
            echo "Download client ${clientConfig.name} does not exist, creating..."

            SCHEMA=$(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | select(.implementation == "${clientConfig.implementationName}") | @json' || echo "")

          if [ -z "$SCHEMA" ]; then
            echo "Error: No schema found for download client implementation ${clientConfig.implementationName}"
            echo "Available implementations: $(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '[.[].implementation] | join(", ")')"
            exit 1
          fi

          NEW_CLIENT=$(${pkgs.jq}/bin/jq -n \
              --arg name "${clientConfig.name}" \
              --arg implName "${clientConfig.implementationName}" \
              --arg apiKey "$CLIENT_API_KEY" \
              --argjson overrides "$FIELD_OVERRIDES" \
              --argjson schema "$SCHEMA" \
              '{
                name: $name,
                enable: true,
                priority: 1,
                implementation: $implName,
                implementationName: $implName,
                configContract: $schema.configContract,
                fields: $schema.fields |
                  map(if .name == "apiKey" then .value = $apiKey
                       elif (.name | IN($overrides | keys[])) then .value = $overrides[.name]
                       else .
                       end)
              }')

            echo "Creating download client with payload:"
            echo "$NEW_CLIENT"

            echo "Creating download client..."
            CREATE_RESPONSE=$(${pkgs.curl}/bin/curl -sS -w "\n%{http_code}" -X POST \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$NEW_CLIENT" \
              "$BASE_URL/downloadclient")

            HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
            RESPONSE_BODY=$(echo "$CREATE_RESPONSE" | head -n -1)

            if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ]; then
              echo "Download client ${clientConfig.name} created (HTTP $HTTP_CODE)"
            else
              echo "Failed to create download client (HTTP $HTTP_CODE)"
              echo "Response: $RESPONSE_BODY"
              exit 1
            fi
          fi
        '') serviceConfig.downloadClients}

        echo "${capitalizedName} download clients configuration complete"
      '';
    };

  mkApplicationsService =
    serviceName: serviceConfig:
    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} applications via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "api_key:${serviceConfig.apiKeyPath}"
        ]
        ++ map (
          app: "app_api_${lib.replaceStrings [ " " ] [ "-" ] (lib.toLower app.name)}:${app.apiKeyPath}"
        ) serviceConfig.applications;
        ExecStartPre = import ./wait-for-api.nix {
          inherit
            lib
            pkgs
            serviceName
            serviceConfig
            ;
        };
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching application schemas..."
        echo "URL: $BASE_URL/applications/schema"
        SCHEMAS=$(${pkgs.curl}/bin/curl -sS -w "\nHTTP_CODE:%{http_code}" -H "X-Api-Key: $API_KEY" "$BASE_URL/applications/schema")
        HTTP_CODE=$(echo "$SCHEMAS" | grep "HTTP_CODE:" | cut -d: -f2)
        SCHEMAS=$(echo "$SCHEMAS" | grep -v "HTTP_CODE:")
        echo "HTTP Status: $HTTP_CODE"
        echo "Schemas response: $SCHEMAS"

        if [ -z "$SCHEMAS" ]; then
          echo "Error: Empty response from schemas API"
          exit 1
        fi

        echo "Fetching existing applications..."
        APPLICATIONS=$(${pkgs.curl}/bin/curl -sS -w "\nHTTP_CODE:%{http_code}" -H "X-Api-Key: $API_KEY" "$BASE_URL/applications")
        APP_HTTP_CODE=$(echo "$APPLICATIONS" | grep "HTTP_CODE:" | cut -d: -f2)
        APPLICATIONS=$(echo "$APPLICATIONS" | grep -v "HTTP_CODE:")
        echo "Applications HTTP Status: $APP_HTTP_CODE"

        CONFIGURED_NAMES=$(cat <<'EOF'
        ${builtins.toJSON (map (a: a.name) serviceConfig.applications)}
        EOF
        )

        echo "Removing all configured applications for clean recreation..."
        echo "$APPLICATIONS" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r app; do
          APP_NAME=$(echo "$app" | ${pkgs.jq}/bin/jq -r '.name')
          APP_ID=$(echo "$app" | ${pkgs.jq}/bin/jq -r '.id')

          echo "Deleting application: $APP_NAME (ID: $APP_ID)"
          ${pkgs.curl}/bin/curl -sSf -X DELETE \
            -H "X-Api-Key: $API_KEY" \
            "$BASE_URL/applications/$APP_ID" >/dev/null || echo "Warning: Failed to delete application $APP_NAME"
        done

        ${lib.concatMapStringsSep "\n" (appConfig: ''
          echo "Creating application: ${appConfig.name}"

          APP_API_KEY=$(cat $CREDENTIALS_DIRECTORY/app_api_${
            lib.replaceStrings [ " " ] [ "-" ] (lib.toLower appConfig.name)
          })

          SCHEMA=$(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | select(.implementation == "${appConfig.implementationName}") | @json' || echo "")

          if [ -z "$SCHEMA" ]; then
            echo "Error: No schema found for application implementation ${appConfig.implementationName}"
            echo "All schemas: $SCHEMAS"
            echo "Available implementations: $(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '[.[].implementation] | join(", ")')" || echo "Could not parse implementations"
            echo "Trying to find with name: $(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | "\(.name) - \(.implementation)"' || echo "Could not parse names")"
            exit 1
          fi

          NEW_APP=$(echo "$SCHEMA" | ${pkgs.jq}/bin/jq \
              --arg name "${appConfig.name}" \
              --arg apiKey "$APP_API_KEY" \
              --arg baseUrl "${appConfig.baseUrl}" \
              --arg prowlarrUrl "${appConfig.prowlarrUrl}" \
              --arg syncLevel "${appConfig.syncLevel}" \
              '{
                name: $name,
                implementation: .implementation,
                implementationName: .implementation,
                configContract: .configContract,
                syncLevel: $syncLevel,
                fields: (.fields // []) |
                  map(
                    if .name == "apiKey" then .value = $apiKey
                    elif .name == "baseUrl" then .value = $baseUrl
                    elif .name == "prowlarrUrl" then .value = $prowlarrUrl
                    else .
                    end
                  )
              }')

          ${pkgs.curl}/bin/curl -sSf -X POST \
            -H "X-Api-Key: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "$NEW_APP" \
            "$BASE_URL/applications" >/dev/null

          echo "Application ${appConfig.name} created"
        '') serviceConfig.applications}

        echo "${capitalizedName} applications configuration complete"
      '';
    };

  mkIndexersService =
    serviceName: serviceConfig:
    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} indexers via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "api_key:${serviceConfig.apiKeyPath}"
        ]
        ++ map (
          i: "indexer_api_${lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower i.name)}:${i.apiKeyPath}"
        ) (builtins.filter (i: i.apiKeyPath != null) serviceConfig.indexers)
        ++ lib.flatten (
          map (
            i:
            map (
              c: "indexer_${lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower i.name)}_${c.baseName}:${c.path}"
            ) (i.credentialsPaths or [ ])
          ) serviceConfig.indexers
        );
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching indexer schemas..."
        SCHEMAS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/indexer/schema")

        echo "Fetching existing indexers..."
        INDEXERS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/indexer")

        echo "Fetching existing tags..."
        EXISTING_TAGS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/tag")

        CONFIGURED_NAMES=$(cat <<'EOF'
        ${builtins.toJSON (map (i: i.name) serviceConfig.indexers)}
        EOF
        )

        echo "Removing indexers not in configuration..."
        echo "$INDEXERS" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r indexer; do
          INDEXER_NAME=$(echo "$indexer" | ${pkgs.jq}/bin/jq -r '.name')
          INDEXER_ID=$(echo "$indexer" | ${pkgs.jq}/bin/jq -r '.id')

          if ! echo "$CONFIGURED_NAMES" | ${pkgs.jq}/bin/jq -e --arg name "$INDEXER_NAME" 'index($name)' >/dev/null 2>&1; then
            echo "Deleting indexer not in config: $INDEXER_NAME (ID: $INDEXER_ID)"
            ${pkgs.curl}/bin/curl -sSf -X DELETE \
              -H "X-Api-Key: $API_KEY" \
              "$BASE_URL/indexer/$INDEXER_ID" >/dev/null || echo "Warning: Failed to delete indexer $INDEXER_NAME"
          fi
        done

        ${lib.concatMapStringsSep "\n" (indexerConfig: ''
          echo "Processing indexer: ${indexerConfig.name}"

          ${lib.optionalString (indexerConfig.apiKeyPath != null) ''
            INDEXER_API_KEY=$(cat $CREDENTIALS_DIRECTORY/indexer_api_${
              lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower indexerConfig.name)
            })
          ''}

          ${lib.optionalString (indexerConfig ? credentialsPaths && indexerConfig.credentialsPaths != [ ]) ''
            CREDENTIAL_OVERRIDES=$(${pkgs.jq}/bin/jq -n '{}')
            ${lib.concatMapStringsSep "\n" (cred: ''
              CREDENTIAL_VALUE=$(cat $CREDENTIALS_DIRECTORY/indexer_${
                lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower indexerConfig.name)
              }_${cred.baseName})
              CREDENTIAL_OVERRIDES=$(echo "$CREDENTIAL_OVERRIDES" | ${pkgs.jq}/bin/jq --arg value "$CREDENTIAL_VALUE" --arg key "${cred.baseName}" '. + { ($key): $value }')
            '') indexerConfig.credentialsPaths}
          ''}

          TAG_IDS="[]"
          ALL_OVERRIDES=$(${pkgs.jq}/bin/jq -n \
            --argjson config '${
              builtins.toJSON (
                builtins.removeAttrs indexerConfig [
                  "name"
                  "apiKeyPath"
                  "credentialsPaths"
                  "appProfileId"
                ]
              )
            }' \
            '$config')
          TOPLEVEL_OVERRIDES=$(${pkgs.jq}/bin/jq -n --argjson all "$ALL_OVERRIDES" '$all | del(.tags) | with_entries(select(.key != "priority" and .key != "downloadClientId" and .key != "rss")) + {appProfileId: 1}')
          FIELD_OVERRIDES=$(${pkgs.jq}/bin/jq -n --argjson all "$ALL_OVERRIDES" '$all | with_entries(select(.value != null and (.key | startswith("_") | not) and .key != "tags" and .key != "priority" and .key != "downloadClientId" and .key != "rss"))')

          EXISTING_INDEXER=$(echo "$INDEXERS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${indexerConfig.name}") | @json' || echo "")

          ${lib.optionalString (indexerConfig.tags != [ ]) ''
            echo "Processing tags for indexer ${indexerConfig.name}..."

            ${builtins.foldl' (acc: tag: ''
              ${acc}
              TAG_LABEL="${tag}"
              TAG_ID=$(echo "$EXISTING_TAGS" | ${pkgs.jq}/bin/jq -r ".[] | select(.label == \"$TAG_LABEL\") | .id")

              if [ -z "$TAG_ID" ] || [ "$TAG_ID" = "null" ]; then
                echo "Tag $TAG_LABEL does not exist, creating..."
                TAG_RESPONSE=$(${pkgs.curl}/bin/curl -sS -X POST \
                  -H "X-Api-Key: $API_KEY" \
                  -H "Content-Type: application/json" \
                  -d "{\"label\":\"$TAG_LABEL\"}" \
                  "$BASE_URL/tag")
                TAG_ID=$(echo "$TAG_RESPONSE" | ${pkgs.jq}/bin/jq -r '.id')
                echo "Tag $TAG_LABEL created with ID: $TAG_ID"
              fi

              TAG_IDS=$(echo "$TAG_IDS" | ${pkgs.jq}/bin/jq -c --arg id "$TAG_ID" '. + [$id | tonumber]')
            '') "" indexerConfig.tags}
          ''}

          if [ -n "$EXISTING_INDEXER" ]; then
            echo "Indexer ${indexerConfig.name} already exists, updating..."
            INDEXER_ID=$(echo "$EXISTING_INDEXER" | ${pkgs.jq}/bin/jq -r '.id')

            UPDATED_INDEXER=$(${pkgs.jq}/bin/jq -n \
              --argjson overrides "$FIELD_OVERRIDES" \
              --argjson topLevel "$TOPLEVEL_OVERRIDES" \
              --argjson existing "$EXISTING_INDEXER" \
              --arg tagIds "$TAG_IDS" \
              '$existing | .enable = true | . + $topLevel | .fields = (.fields | map(select(.name != "tags"))) + ($overrides | to_entries | map({name: .key, value: .value})) | .tags = ($tagIds | fromjson)')

            ${lib.optionalString (indexerConfig.apiKeyPath != null) ''
              UPDATED_INDEXER=$(echo "$UPDATED_INDEXER" | ${pkgs.jq}/bin/jq \
                --arg apiKey "$INDEXER_API_KEY" \
                '.fields |= (if any(.name == "apiKey") then (.[] | if .name == "apiKey" then .value = $apiKey else . end) else .)')
            ''}

            ${lib.optionalString (indexerConfig ? credentialsPaths && indexerConfig.credentialsPaths != [ ])
              ''
                UPDATED_INDEXER=$(echo "$UPDATED_INDEXER" | ${pkgs.jq}/bin/jq \
                  --argjson credentials "$CREDENTIAL_OVERRIDES" \
                  '.fields |= map(. + if ($credentials[.name] != null) then {value: $credentials[.name]} else {} end)')
              ''
            }

            ${pkgs.curl}/bin/curl -sSf -X PUT \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$UPDATED_INDEXER" \
              "$BASE_URL/indexer/$INDEXER_ID" >/dev/null

            echo "Indexer ${indexerConfig.name} updated"
          else
            echo "Indexer ${indexerConfig.name} does not exist, creating..."

            SCHEMA=$(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${indexerConfig.name}") | @json' || echo "")

            if [ -z "$SCHEMA" ]; then
              echo "Error: No schema found for indexer ${indexerConfig.name}"
              exit 1
            fi

            NEW_INDEXER=$(${pkgs.jq}/bin/jq -n \
              --argjson overrides "$FIELD_OVERRIDES" \
              --argjson topLevel "$TOPLEVEL_OVERRIDES" \
              --argjson schema "$SCHEMA" \
              --arg tagIds "$TAG_IDS" \
              '$schema | .enable = true | . + $topLevel | .fields = (.fields | map(select(.name != "tags"))) + ($overrides | to_entries | map({name: .key, value: .value})) | .tags = ($tagIds | fromjson)')

            ${lib.optionalString (indexerConfig.apiKeyPath != null) ''
              NEW_INDEXER=$(echo "$NEW_INDEXER" | ${pkgs.jq}/bin/jq \
                --arg apiKey "$INDEXER_API_KEY" \
                '.fields |= (if any(.name == "apiKey") then (.[] | if .name == "apiKey" then .value = $apiKey else . end) else .)')
            ''}

            ${lib.optionalString (indexerConfig ? credentialsPaths && indexerConfig.credentialsPaths != [ ])
              ''
                NEW_INDEXER=$(echo "$NEW_INDEXER" | ${pkgs.jq}/bin/jq \
                  --argjson credentials "$CREDENTIAL_OVERRIDES" \
                  '.fields |= map(. + if ($credentials[.name] != null) then {value: $credentials[.name]} else {} end)')
              ''
            }

            ${pkgs.curl}/bin/curl -sSf -X POST \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$NEW_INDEXER" \
              "$BASE_URL/indexer" >/dev/null

            echo "Indexer ${indexerConfig.name} created"
          fi
        '') serviceConfig.indexers}

        echo "${capitalizedName} indexers configuration complete"
      '';
    };

  mkIndexerProxiesService =
    serviceName: serviceConfig:

    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} indexer proxies via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [ "api_key:${serviceConfig.apiKeyPath}" ];
        ExecStartPre = import ./wait-for-api.nix {
          inherit
            lib
            pkgs
            serviceName
            serviceConfig
            ;
        };
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching indexer proxy schemas..."
        SCHEMAS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/indexerproxy/schema")

        echo "Fetching existing indexer proxies..."
        PROXIES=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/indexerproxy")

        echo "Fetching existing tags..."
        EXISTING_TAGS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/tag")

        ${lib.concatMapStringsSep "\n" (proxyConfig: ''
          echo "Processing indexer proxy: ${proxyConfig.name}"

          TAG_IDS="[]"
          ${lib.optionalString (proxyConfig.tags != [ ]) ''
            ${builtins.foldl' (acc: tag: ''
              ${acc}
              TAG_LABEL="${tag}"
              TAG_ID=$(echo "$EXISTING_TAGS" | ${pkgs.jq}/bin/jq -r ".[] | select(.label == \"$TAG_LABEL\") | .id")

              if [ -z "$TAG_ID" ] || [ "$TAG_ID" = "null" ]; then
                echo "Tag $TAG_LABEL does not exist, creating..."
                TAG_RESPONSE=$(${pkgs.curl}/bin/curl -sS -X POST \
                  -H "X-Api-Key: $API_KEY" \
                  -H "Content-Type: application/json" \
                  -d "{\"label\":\"$TAG_LABEL\"}" \
                  "$BASE_URL/tag")
                TAG_ID=$(echo "$TAG_RESPONSE" | ${pkgs.jq}/bin/jq -r '.id')
                echo "Tag $TAG_LABEL created with ID: $TAG_ID"
              fi

              TAG_IDS=$(echo "$TAG_IDS" | ${pkgs.jq}/bin/jq -c --arg id "$TAG_ID" '. + [$id | tonumber]')
            '') "" proxyConfig.tags}
          ''}

          EXISTING_PROXY=$(echo "$PROXIES" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${proxyConfig.name}") | @json' || echo "")

          if [ -n "$EXISTING_PROXY" ]; then
            echo "Indexer proxy ${proxyConfig.name} already exists, updating..."
            PROXY_ID=$(echo "$EXISTING_PROXY" | ${pkgs.jq}/bin/jq -r '.id')

            UPDATED_PROXY=$(echo "$EXISTING_PROXY" | ${pkgs.jq}/bin/jq \
              --arg hostUrl "${proxyConfig.hostUrl}" \
              --argjson requestTimeout ${builtins.toString proxyConfig.requestTimeout} \
              --argjson tagIds "$TAG_IDS" \
              '.fields |= (map(if .name == "hostUrl" then .value = $hostUrl elif .name == "requestTimeout" then .value = $requestTimeout else . end)) | .tags = $tagIds')

            ${pkgs.curl}/bin/curl -sSf -X PUT \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$UPDATED_PROXY" \
              "$BASE_URL/indexerproxy/$PROXY_ID" >/dev/null

            echo "Indexer proxy ${proxyConfig.name} updated"
          else
            echo "Indexer proxy ${proxyConfig.name} does not exist, creating..."

            SCHEMA=$(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | select(.implementation == "${proxyConfig.implementation}") | @json' || echo "")

            if [ -z "$SCHEMA" ]; then
              echo "Error: No schema found for indexer proxy implementation ${proxyConfig.implementation}"
              exit 1
            fi

            NEW_PROXY=$(echo "$SCHEMA" | ${pkgs.jq}/bin/jq \
              --arg name "${proxyConfig.name}" \
              --arg hostUrl "${proxyConfig.hostUrl}" \
              --argjson requestTimeout ${builtins.toString proxyConfig.requestTimeout} \
              --argjson tagIds "$TAG_IDS" \
              '.name = $name | .fields |= (map(if .name == "hostUrl" then .value = $hostUrl elif .name == "requestTimeout" then .value = $requestTimeout else . end)) | .tags = $tagIds')

            ${pkgs.curl}/bin/curl -sSf -X POST \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$NEW_PROXY" \
              "$BASE_URL/indexerproxy" >/dev/null

            echo "Indexer proxy ${proxyConfig.name} created"
          fi
        '') serviceConfig.proxies}

        echo "${capitalizedName} indexer proxies configuration complete"
      '';
    };

  mkInstancesService =
    serviceName: serviceConfig:

    let
      capitalizedName =
        lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
    in
    {
      description = "Configure ${capitalizedName} Sonarr/Radarr instances via API";
      after = [ "${serviceName}-config-host.service" ];
      requires = [ "${serviceName}-config-host.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "api_key:${serviceConfig.apiKeyPath}"
        ]
        ++ map (
          i: "instance_api_${lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower i.name)}:${i.apiKeyPath}"
        ) serviceConfig.instances;
      };

      script = ''
        set -eu

        API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
        BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

        echo "Fetching instance schemas..."
        SCHEMAS=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/instance/schema")

        echo "Fetching existing instances..."
        INSTANCES=$(${pkgs.curl}/bin/curl -sS -H "X-Api-Key: $API_KEY" "$BASE_URL/instance")

        CONFIGURED_NAMES=$(cat <<'EOF'
        ${builtins.toJSON (map (i: i.name) serviceConfig.instances)}
        EOF
        )

        echo "Removing instances not in configuration..."
        echo "$INSTANCES" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r instance; do
          INSTANCE_NAME=$(echo "$instance" | ${pkgs.jq}/bin/jq -r '.name')
          if ! echo "$CONFIGURED_NAMES" | ${pkgs.jq}/bin/jq -e --arg name "$INSTANCE_NAME" 'index($name)' >/dev/null 2>&1; then
            INSTANCE_ID=$(echo "$instance" | ${pkgs.jq}/bin/jq -r '.id')
            echo "Deleting instance not in config: $INSTANCE_NAME (ID: $INSTANCE_ID)"
            ${pkgs.curl}/bin/curl -sSf -X DELETE \
              -H "X-Api-Key: $API_KEY" \
              "$BASE_URL/instance/$INSTANCE_ID" >/dev/null || echo "Warning: Failed to delete instance $INSTANCE_NAME"
          fi
        done

        ${lib.concatMapStringsSep "\n" (instanceConfig: ''
          echo "Processing instance: ${instanceConfig.name}"

          INSTANCE_API_KEY=$(cat $CREDENTIALS_DIRECTORY/instance_api_${
            lib.replaceStrings [ "-" ] [ "_" ] (lib.toLower instanceConfig.name)
          })

          ALL_OVERRIDES=$(${pkgs.jq}/bin/jq -n \
            --arg hostname "${instanceConfig.hostname}" \
            --arg port "${toString (instanceConfig.port or 80)}" \
            --arg baseUrl "${instanceConfig.baseUrl or ""}" \
            --argjson ssl ${if instanceConfig.ssl or false then "true" else "false"} \
            --argjson isDefault ${if instanceConfig.is_default or false then "true" else "false"} \
            '{hostname: $hostname, port: ($port | tonumber), baseUrl: $baseUrl, ssl: $ssl, isDefault: $isDefault}')

          EXISTING_INSTANCE=$(echo "$INSTANCES" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "${instanceConfig.name}") | @json' || echo "")

          if [ -n "$EXISTING_INSTANCE" ]; then
            echo "Instance ${instanceConfig.name} already exists, updating..."
            INSTANCE_ID=$(echo "$EXISTING_INSTANCE" | ${pkgs.jq}/bin/jq -r '.id')

            UPDATED_INSTANCE=$(echo "$EXISTING_INSTANCE" | ${pkgs.jq}/bin/jq \
              --arg apiKey "$INSTANCE_API_KEY" \
              --argjson overrides "$ALL_OVERRIDES" \
              '$existing | .apiKey = $apiKey | . + $overrides')

            ${pkgs.curl}/bin/curl -sSf -X PUT \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$UPDATED_INSTANCE" \
              "$BASE_URL/instance/$INSTANCE_ID"

            echo "Instance ${instanceConfig.name} updated"
          else
            echo "Instance ${instanceConfig.name} does not exist, creating..."

            SCHEMA=$(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '.[] | select(.implementation == "${instanceConfig.implementation}") | @json' || echo "")

            if [ -z "$SCHEMA" ]; then
              echo "Error: No schema found for instance implementation ${instanceConfig.implementation}"
              echo "Available implementations: $(echo "$SCHEMAS" | ${pkgs.jq}/bin/jq -r '[.[].implementation] | join(", ")')" || echo "Could not parse implementations"
              exit 1
            fi

            NEW_INSTANCE=$(echo "$SCHEMA" | ${pkgs.jq}/bin/jq \
              --arg name "${instanceConfig.name}" \
              --arg apiKey "$INSTANCE_API_KEY" \
              --argjson overrides "$ALL_OVERRIDES" \
              --argjson schema "$SCHEMA" \
              '{
                name: $name,
                implementation: .implementation,
                implementationName: .implementation,
                configContract: .configContract,
                isDefault: $overrides.isDefault
              } as $base
              | $base + {
                apiKey: $apiKey
              } | .fields |= (.schema.fields // []) | map(
                if .name == "hostname" then .value = $overrides.hostname
                elif .name == "port" then .value = $overrides.port
                elif .name == "baseUrl" then .value = $overrides.baseUrl
                elif .name == "ssl" then .value = $overrides.ssl
                elif .name == "isDefault" then .value = $overrides.isDefault
                else .
                end
              )')

            ${pkgs.curl}/bin/curl -sSf -X POST \
              -H "X-Api-Key: $API_KEY" \
              -H "Content-Type: application/json" \
              -d "$NEW_INSTANCE" \
              "$BASE_URL/instance"

            echo "Instance ${instanceConfig.name} created"
          fi
        '') serviceConfig.instances}

        echo "${capitalizedName} instances configuration complete"
      '';
    };

in
{
  inherit
    mkHostConfigService
    mkRootFoldersService
    mkDownloadClientsService
    mkApplicationsService
    mkIndexersService
    mkIndexerProxiesService
    mkInstancesService
    ;
}
