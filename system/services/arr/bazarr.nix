{ config, ... }:
{
  homelab.subdomains = [ "bazarr" ];
  services.bazarr = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "bazarr.${config.homelab.domain}";
    };
    urlBase = "/";
    listenPort = 6767;

    apiConfig = {
      enable = true;
      apiKeyPath = config.sops.secrets."bazarr/api_key".path;

      instances = [
        {
          name = "Radarr";
          implementation = "Radarr";
          hostname = "127.0.0.1";
          port = 7878;
          apiKeyPath = config.sops.secrets."radarr/api_key".path;
          baseUrl = "";
          is_default = true;
        }
        {
          name = "Sonarr TV";
          implementation = "Sonarr";
          hostname = "127.0.0.1";
          port = 8989;
          apiKeyPath = config.sops.secrets."sonarr/api_key".path;
          baseUrl = "";
        }
        {
          name = "Sonarr Anime";
          implementation = "Sonarr";
          hostname = "127.0.0.1";
          port = 8990;
          apiKeyPath = config.sops.secrets."sonarr-anime/api_key".path;
          baseUrl = "";
        }
        {
          name = "Sonarr KDrama";
          implementation = "Sonarr";
          hostname = "127.0.0.1";
          port = 8991;
          apiKeyPath = config.sops.secrets."sonarr-kdrama/api_key".path;
          baseUrl = "";
        }
      ];

      languages = {
        enabled = [ "en" ];
        series = {
          languages = [ "en" ];
          hearingImpaired = false;
          forced = false;
        };
        movies = {
          languages = [ "en" ];
          hearingImpaired = false;
          forced = false;
        };
      };
    };
  };

  sops.secrets."bazarr/api_key" = {
    owner = "bazarr";
    group = "bazarr";
  };
}
