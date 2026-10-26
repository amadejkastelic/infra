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
  asianReleaseGroups = "dad6a8cceaa4fee536eaec55201c70c3";
  streamingServices = {
    amzn = "d660701077794679fd59e8bdf4ce3a29";
    nf = "d34870697c9db575f17700212167be23";
    tving = "86f8d3b8761de651aa355d46d5d8db3e";
    viki = "932d0a3499cc4c529fb86e3adf1326d9";
    viu = "93c9d1e566dca8b34d57f5efbbf85f28";
    wavve = "50421fc8b3734d2863561714d343e449";
    wetv = "932fafe503110be779ae49342dfad30b";
    kcw = "8620e171f1a67cff092e86e65bb29c76";
  };
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
        custom_format_groups.add = [
          {
            trash_id = asianReleaseGroups;
            select_all = true;
          }
        ];
        custom_formats = [
          {
            trash_ids = builtins.attrValues streamingServices;
            assign_scores_to = [ { trash_id = web2160pCombined; } ];
          }
        ];
      };
    };
  };
}
