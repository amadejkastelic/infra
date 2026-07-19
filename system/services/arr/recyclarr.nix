{ config, ... }:
let
  inherit (config.services)
    sonarr
    sonarr-anime
    sonarr-kdrama
    radarr
    ;

  web2160pCombined = "c4cadd6b35b95f62c3d47a408e53e2f7";
  animeRemux1080p = "20e0fc959f1f1704bed501f23bdae76f";
  remuxWeb2160p = "fd161a61e3ab826d3a22d53f935696dd";
in
{
  services.recyclarr = {
    enable = true;
    command = "sync";
    schedule = "*-*-* 03:00:00";

    configuration = {
      radarr.radarr = {
        base_url = "http://127.0.0.1:${toString radarr.settings.server.port}";
        api_key._secret = config.sops.secrets."radarr/api_key".path;
        quality_definition.type = "movie";
        quality_profiles = [
          {
            trash_id = remuxWeb2160p;
            reset_unmatched_scores.enabled = true;
          }
        ];
      };

      sonarr.sonarr-tv = {
        base_url = "http://127.0.0.1:${toString sonarr.settings.server.port}";
        api_key._secret = config.sops.secrets."sonarr/api_key".path;
        quality_definition.type = "series";
        quality_profiles = [
          {
            trash_id = web2160pCombined;
            reset_unmatched_scores.enabled = true;
          }
        ];
      };

      sonarr.sonarr-anime = {
        base_url = "http://127.0.0.1:${toString sonarr-anime.settings.server.port}";
        api_key._secret = config.sops.secrets."sonarr-anime/api_key".path;
        quality_definition.type = "anime";
        quality_profiles = [
          {
            trash_id = animeRemux1080p;
            reset_unmatched_scores.enabled = true;
          }
        ];
        custom_format_groups.add = [
          {
            trash_id = "f54985e5e96747cef58731f1cf4c9181";
            select_all = true;
          }
        ];
        custom_formats = [
          {
            trash_ids = [ "026d5aadd1a6b4e550b134cb6c72b3ca" ];
            assign_scores_to = [
              {
                trash_id = animeRemux1080p;
                score = 101;
              }
            ];
          }
        ];
      };

      sonarr.sonarr-kdrama = {
        base_url = "http://127.0.0.1:${toString sonarr-kdrama.settings.server.port}";
        api_key._secret = config.sops.secrets."sonarr-kdrama/api_key".path;
        quality_definition.type = "series";
        quality_profiles = [
          {
            trash_id = web2160pCombined;
            reset_unmatched_scores.enabled = true;
          }
        ];
      };
    };
  };
}
