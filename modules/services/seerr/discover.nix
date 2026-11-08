{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seerr;
  baseUrl = "http://127.0.0.1:${toString cfg.port}";
  cookieFile = "/run/seerr/cookies.txt";

  sliderTypes = {
    "tmdb-movie-keyword" = 13;
    "tmdb-movie-genre" = 14;
    "tmdb-tv-keyword" = 15;
    "tmdb-tv-genre" = 16;
    "tmdb-search" = 17;
    "tmdb-movie-studio" = 18;
    "tmdb-tv-network" = 19;
  };

  wantedSliders = map (
    s:
    s
    // {
      typeId = sliderTypes.${s.type};
    }
  ) cfg.discover.sliders;

  wantedJson = pkgs.writeText "seerr-discover-sliders.json" (
    builtins.toJSON (
      map (s: {
        inherit (s) title data enabled;
        type = s.typeId;
      }) wantedSliders
    )
  );
in

{
  config = lib.mkIf (cfg.enable && cfg.discover.sliders != [ ]) {
    systemd.services.seerr-discover = {
      description = "Configure Seerr Discover sliders";
      after = [ "seerr-setup.service" ];
      requires = [ "seerr-setup.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        BASE_URL="${baseUrl}"

        for i in {1..60}; do
          if ${pkgs.curl}/bin/curl -sf "$BASE_URL/api/v1/status" >/dev/null 2>&1; then
            break
          fi
          sleep 1
        done

        CURRENT=$(${pkgs.curl}/bin/curl -sf -b "${cookieFile}" "$BASE_URL/api/v1/settings/discover")

        ${lib.concatMapStringsSep "\n" (s: ''
          SLIDER_ID=$(echo "$CURRENT" | ${pkgs.jq}/bin/jq -r --arg title "${s.title}" \
            '.[] | select(.isBuiltIn == false and .title == $title) | .id')
          SLIDER_PAYLOAD=$(${pkgs.jq}/bin/jq -n \
            --arg title "${s.title}" \
            --arg data "${s.data}" \
            --argjson type ${toString s.typeId} \
            '{title: $title, data: $data, type: $type}')

          if [ -n "$SLIDER_ID" ] && [ "$SLIDER_ID" != "null" ]; then
            echo "Updating Discover slider '${s.title}' (ID: $SLIDER_ID)..."
            ${pkgs.curl}/bin/curl -sf -X PUT \
              -b "${cookieFile}" \
              -H "Content-Type: application/json" \
              -d "$SLIDER_PAYLOAD" \
              "$BASE_URL/api/v1/settings/discover/$SLIDER_ID" >/dev/null
          else
            echo "Creating Discover slider '${s.title}'..."
            ${pkgs.curl}/bin/curl -sf -X POST \
              -b "${cookieFile}" \
              -H "Content-Type: application/json" \
              -d "$SLIDER_PAYLOAD" \
              "$BASE_URL/api/v1/settings/discover/add" >/dev/null
          fi
        '') wantedSliders}

        WANTED_TITLES=$(echo "$CURRENT" | ${pkgs.jq}/bin/jq -r \
          --slurpfile wanted "${wantedJson}" \
          '.[] | select(.isBuiltIn == false) as $s
          | select(($wanted[0] | map(.title) | index($s.title)) == null)
          | "\($s.id) \($s.title)"')

        while read -r slider_id slider_title; do
          if [ -z "$slider_id" ]; then
            continue
          fi
          echo "Deleting Discover slider '$slider_title' (ID: $slider_id)..."
          ${pkgs.curl}/bin/curl -sf -X DELETE \
            -b "${cookieFile}" \
            "$BASE_URL/api/v1/settings/discover/$slider_id" >/dev/null
        done <<<"$WANTED_TITLES"

        CURRENT=$(${pkgs.curl}/bin/curl -sf -b "${cookieFile}" "$BASE_URL/api/v1/settings/discover")

        FINAL=$(echo "$CURRENT" | ${pkgs.jq}/bin/jq -c \
          --slurpfile wanted "${wantedJson}" \
          '. as $current
          | [ $current[] | select(.isBuiltIn == true) | {id: .id, type: .type, title: .title, data: .data, enabled: .enabled} ]
            + [ $wanted[0][]
                | . as $w
                | {
                    id: ($current[] | select(.isBuiltIn == false and .title == $w.title) | .id),
                    type: $w.type,
                    title: $w.title,
                    data: $w.data,
                    enabled: $w.enabled,
                  } ]')

        echo "Applying Discover slider order and visibility..."
        ${pkgs.curl}/bin/curl -sf -X POST \
          -b "${cookieFile}" \
          -H "Content-Type: application/json" \
          -d "$FINAL" \
          "$BASE_URL/api/v1/settings/discover" >/dev/null

        echo "Discover slider configuration completed"
      '';
    };
  };
}
