{ config, ... }:
let
  category = "kdrama";
  dir = "${config.nas.mediaDir}/${category}";
in
{
  services.sonarr-kdrama = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "sonarr-kdrama.amadejk.com";
    };

    settings = {
      log.analyticsEnabled = false;
      update.automatically = false;
      server.port = 8991;
      auth = {
        authenticationMethod = "External";
        authenticationRequired = "DisabledForLocalAddresses";
      };
    };

    apiConfig = {
      enable = true;
      apiKeyPath = config.sops.secrets."sonarr-kdrama/api_key".path;
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

  sops.secrets."sonarr-kdrama/api_key" = {
    owner = "sonarr-kdrama";
    group = "sonarr-kdrama";
  };

  systemd.tmpfiles.settings."sonarr-kdrama" = {
    "${dir}".d = {
      user = "sonarr-kdrama";
      group = "media";
      mode = "0775";
    };
  };
}
