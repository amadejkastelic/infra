{
  meters ? [ ],
  port ? 8123,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  base = "http://127.0.0.1:${toString port}";
  clientId = "http://mojelektro-config.local/";
in
lib.mkIf (meters != [ ]) {
  systemd.services.home-assistant-mojelektro = {
    description = "Configure Home Assistant Moj Elektro config entries via API";
    after = [ "home-assistant.service" ];
    wants = [ "home-assistant.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "20min";
      LoadCredential = [ "mojelektro_token:${config.sops.secrets."mojelektro/token".path}" ];
    };

    script = ''
      set -eu

      BASE_URL="${base}"
      XFF="X-Forwarded-For: 127.0.0.2"
      CLIENT_ID="${clientId}"
      MJ_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/mojelektro_token")

      CODE=""
      for i in $(seq 1 230); do
        RESPONSE=$(${pkgs.curl}/bin/curl -s -m 10 -X POST "$BASE_URL/auth/login_flow" \
          -H "Content-Type: application/json" -H "$XFF" \
          -d "{\"client_id\":\"$CLIENT_ID\",\"handler\":[\"trusted_networks\",null],\"redirect_uri\":\"$CLIENT_ID\"}") || { sleep 5; continue; }

        TYPE=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.type')
        if [ "$TYPE" = "create_entry" ]; then
          CODE=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.result')
          break
        fi
        if [ "$TYPE" = "abort" ] && [ "$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.reason')" = "not_allowed" ]; then
          sleep 5
          continue
        fi
        echo "Unexpected login flow response: $RESPONSE" >&2
        exit 1
      done

      if [ -z "$CODE" ]; then
        echo "Timed out waiting for Home Assistant" >&2
        exit 1
      fi

      TOKEN=$(${pkgs.curl}/bin/curl -sSf -X POST "$BASE_URL/auth/token" -H "$XFF" \
        --data-urlencode grant_type=authorization_code \
        --data-urlencode "code=$CODE" \
        --data-urlencode "client_id=$CLIENT_ID" \
        | ${pkgs.jq}/bin/jq -r '.access_token')
      AUTH="Authorization: Bearer $TOKEN"

      flow_post() {
        ${pkgs.curl}/bin/curl -sS -X POST "$BASE_URL/api/config/config_entries/flow/$1" \
          -H "$AUTH" -H "$XFF" -H "Content-Type: application/json" -d "$2"
      }

      flow_check() {
        local flow=$1 step=$2
        local type error_count
        type=$(echo "$flow" | ${pkgs.jq}/bin/jq -r '.type')
        error_count=$(echo "$flow" | ${pkgs.jq}/bin/jq -r '(.errors // {}) | length')
        if [ "$type" = "abort" ] || { [ "$type" = "form" ] && [ "$error_count" -gt 0 ]; }; then
          echo "Flow step $step failed: $flow" >&2
          exit 1
        fi
      }

      EXISTING=$(${pkgs.jq}/bin/jq -r '[.data.entries[]
        | select(.domain == "mojelektro_stats")
        | .data.usage_points[]?.identifikator] | unique | .[]' \
        /var/lib/hass/.storage/core.config_entries 2>/dev/null || true)

      ${lib.concatMapStringsSep "\n" (ident: ''
        IDENT="${ident}"
        if echo "$EXISTING" | grep -qxF "$IDENT"; then
          echo "Config entry for $IDENT already exists"
        else
          echo "Creating config entry for $IDENT"

          FLOW=$(${pkgs.curl}/bin/curl -sS -X POST "$BASE_URL/api/config/config_entries/flow" \
            -H "$AUTH" -H "$XFF" -H "Content-Type: application/json" \
            -d '{"handler":"mojelektro_stats"}')
          flow_check "$FLOW" init

          FLOW=$(flow_post "$(echo "$FLOW" | ${pkgs.jq}/bin/jq -r '.flow_id')" \
            "$(${pkgs.jq}/bin/jq -nc --arg t "$MJ_TOKEN" '{api_token: $t, server: "prod"}')")
          flow_check "$FLOW" user

          FLOW=$(flow_post "$(echo "$FLOW" | ${pkgs.jq}/bin/jq -r '.flow_id')" \
            "$(${pkgs.jq}/bin/jq -nc --arg i "$IDENT" '{identifikator: $i}')")
          flow_check "$FLOW" add_usage_point

          ROUTING=$(echo "$FLOW" | ${pkgs.jq}/bin/jq -c 'reduce .data_schema[].name as $k ({}; .[$k] = ["statistics"])')
          FLOW=$(flow_post "$(echo "$FLOW" | ${pkgs.jq}/bin/jq -r '.flow_id')" "$ROUTING")
          flow_check "$FLOW" configure_measurements

          echo "$FLOW" | ${pkgs.jq}/bin/jq -e '.type == "create_entry"' >/dev/null
          echo "Created config entry for $IDENT"
        fi
      '') meters}
    '';
  };

  sops.secrets."mojelektro/token" = { };
}
