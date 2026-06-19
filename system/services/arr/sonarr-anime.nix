{ config, ... }:
let
  category = "anime";
  dir = "${config.nas.mediaDir}/${category}";
in
{
  services.sonarr-anime = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "sonarr-anime.amadejk.com";
    };

    settings = {
      log.analyticsEnabled = false;
      update.automatically = false;
      server.port = 8990;
      auth = {
        authenticationMethod = "External";
        authenticationRequired = "DisabledForLocalAddresses";
      };
    };

    apiConfig = {
      enable = true;
      apiKeyPath = config.sops.secrets."sonarr-anime/api_key".path;
      rootFolders = [
        { path = dir; }
      ];
      downloadClients = [
        {
          name = "qBittorrent";
          implementationName = "qBittorrent";
          host = "127.0.0.1";
          port = 8088;
          apiKeyPath = config.sops.secrets."qbittorrent/api_key".path;
          category = category;
          importMode = "hardlink";
        }
      ];
    };
  };

  sops.secrets."sonarr-anime/api_key" = {
    owner = "sonarr-anime";
    group = "sonarr-anime";
  };

  systemd.tmpfiles.settings."sonarr-anime" = {
    "${dir}".d = {
      user = "sonarr-anime";
      group = "media";
      mode = "0775";
    };
  };
}
