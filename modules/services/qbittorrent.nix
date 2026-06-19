{
  config,
  lib,
  ...
}:

let
  cfg = config.services.qbittorrent.nginx;
  locationPath = if cfg.location == "" then "/" else "/${cfg.location}/";
in
{
  options.services.qbittorrent.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for qbittorrent";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose qbittorrent webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.qbittorrent.webuiPort;
      description = "Port to expose qbittorrent webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location path to expose qbittorrent webui through nginx";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = { };

    services.qbittorrent.group = lib.mkDefault "media";

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        locations."${locationPath}" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
