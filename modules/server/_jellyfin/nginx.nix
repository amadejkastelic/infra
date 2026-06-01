{
  config,
  lib,
  ...
}:

let
  cfg = config.services.jellyfin.nginx;
in
{
  options.services.jellyfin.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for jellyfin";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose jellyfin webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8096;
      description = "Port to expose jellyfin webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin";
      description = "Location path to expose jellyfin webui through nginx";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        locations."/${cfg.location}/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
