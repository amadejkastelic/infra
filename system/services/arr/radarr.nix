{ config, ... }:
let
  category = "movies";
  dir = "${config.nas.mediaDir}/${category}";
in
{
  homelab.subdomains = [ "radarr" ];
  services.radarr = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "radarr.${config.homelab.domain}";
    };

    settings = {
      log.analyticsEnabled = false;
      update.automatically = false;
      server.port = 7878;
      auth = {
        authenticationMethod = "External";
        authenticationRequired = "DisabledForLocalAddresses";
      };
    };

    apiConfig = {
      enable = true;
      apiKeyPath = config.sops.secrets."radarr/api_key".path;
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

  sops.secrets."radarr/api_key" = {
    owner = "radarr";
    group = "radarr";
  };

  sops.secrets."qbittorrent/api_key" = {
    owner = "qbittorrent";
    group = "media";
  };

  systemd.tmpfiles.settings."radarr" = {
    "${dir}".d = {
      user = "radarr";
      group = "media";
      mode = "0775";
    };
  };
}
