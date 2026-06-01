{
  lib,
  pkgs,
  serviceName,
  serviceConfig,
}:
let
  capitalizedName =
    lib.toUpper (builtins.substring 0 1 serviceName) + builtins.substring 1 (-1) serviceName;
  screamingServiceBase = lib.toUpper (builtins.elemAt (lib.splitString "-" serviceName) 0);
  apiKeyEnvVar = screamingServiceBase + "__AUTH__APIKEY";
in
pkgs.writeShellScript "${serviceName}-wait-for-api" ''
  if [ -n "${"$"}{${apiKeyEnvVar}:-}" ]; then
    API_KEY="${"$"}${apiKeyEnvVar}"
    echo "Using API key from env var ${apiKeyEnvVar}"
  elif [ -n "$CREDENTIALS_DIRECTORY" ] && [ -f "$CREDENTIALS_DIRECTORY/api_key" ]; then
    API_KEY=$(cat $CREDENTIALS_DIRECTORY/api_key)
    echo "Using API key from CREDENTIALS_DIRECTORY"
  else
    API_KEY=$(cat ${serviceConfig.apiKeyPath})
    echo "Using API key from ${serviceConfig.apiKeyPath}"
  fi

  echo "API key: "${"$"}{API_KEY:0:20}"..."

  BASE_URL="http://127.0.0.1:${builtins.toString serviceConfig.hostConfig.port}${serviceConfig.hostConfig.urlBase}/api/${serviceConfig.apiVersion}"

  FULL_URL="$BASE_URL/system/status"
  echo "Full URL: $FULL_URL"

  echo "Waiting for ${capitalizedName} API to be available at $BASE_URL..."
  for i in {1..90}; do
    echo "Attempting: $FULL_URL"
    if ${pkgs.curl}/bin/curl -s -f -H "X-API-Key: $API_KEY" "$FULL_URL" >/dev/null 2>&1; then
      echo "${capitalizedName} API is available"
      sleep 3
      exit 0
    fi
    echo "Waiting for ${capitalizedName} API... ($i/90)"
    sleep 1
  done

  echo "${capitalizedName} API not available after 90 seconds" >&2
  exit 1
''
