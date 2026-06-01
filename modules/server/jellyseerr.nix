{
  den.aspects.jellyseerr.nixos =
    { config, ... }:
    let
      mediaDir = config.nas.mediaDir;
    in
    {
      imports = [ ./_jellyseerr/module.nix ];

      services.seerr = {
        enable = true;

        nginx.enable = true;

        jellyfin = {
          hostname = "127.0.0.1";
          port = config.services.jellyfin.apiConfig.port;
          urlBase = config.services.jellyfin.apiConfig.baseUrl;
          enableAllLibraries = true;
        };

        radarr = [
          {
            name = "Radarr";
            hostname = config.networking.hostName;
            port = config.services.radarr.settings.server.port;
            apiKeyPath = config.sops.secrets."radarr/api_key".path;
            baseUrl = config.services.radarr.settings.server.urlbase;
            isDefault = true;
            is4k = false;
            activeDirectory = "${mediaDir}/movies";
          }
        ];

        sonarr = [
          {
            name = "Sonarr";
            hostname = config.networking.hostName;
            port = config.services.sonarr.settings.server.port;
            apiKeyPath = config.sops.secrets."sonarr/api_key".path;
            baseUrl = config.services.sonarr.settings.server.urlbase;
            isDefault = true;
            is4k = false;
            activeDirectory = "${mediaDir}/tv";
          }
          {
            name = "Sonarr Anime";
            hostname = config.networking.hostName;
            port = config.services.sonarr-anime.settings.server.port;
            apiKeyPath = config.sops.secrets."sonarr-anime/api_key".path;
            baseUrl = config.services.sonarr-anime.settings.server.urlbase;
            isDefault = false;
            is4k = false;
            activeDirectory = "${mediaDir}/tv";
            seriesType = "anime";
          }
          {
            name = "Sonarr K-Drama";
            hostname = config.networking.hostName;
            port = config.services.sonarr-kdrama.settings.server.port;
            apiKeyPath = config.sops.secrets."sonarr-kdrama/api_key".path;
            baseUrl = config.services.sonarr-kdrama.settings.server.urlbase;
            isDefault = false;
            is4k = false;
            activeDirectory = "${mediaDir}/tv";
          }
        ];
      };
    };
}
