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
    settings.general.port = 6767;

    apiConfig = {
      enable = true;
      apiKeyPath = config.sops.secrets."bazarr/api_key".path;

      sonarr = {
        port = 8989;
        apiKeyPath = config.sops.secrets."sonarr/api_key".path;
      };

      radarr = {
        port = 7878;
        apiKeyPath = config.sops.secrets."radarr/api_key".path;
      };

      jellyfin = {
        movieLibrary = [ "Movies" ];
        seriesLibrary = [ "TV Shows" ];
      };

      providers = [
        {
          name = "opensubtitlescom";
          usernamePath = config.sops.secrets."bazarr/opensubtitles/username".path;
          passwordPath = config.sops.secrets."bazarr/opensubtitles/password".path;
        }
        { name = "gestdown"; }
      ];

      languages = { };
    };
  };

  sops.secrets."bazarr/api_key" = {
    owner = "bazarr";
    group = "bazarr";
  };

  sops.secrets = {
    "bazarr/opensubtitles/username" = { };
    "bazarr/opensubtitles/password" = { };
    "avistaz/cookies" = { };
  };
}
