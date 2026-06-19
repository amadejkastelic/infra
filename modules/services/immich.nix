{
  config,
  lib,
  ...
}:

let
  cfg = config.services.immich.nginx;
  locationPath = if cfg.location == "" then "/" else "/${cfg.location}/";
in
{
  options.services.immich.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for Immich";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose Immich through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.immich.port;
      description = "Port to expose Immich through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location path to expose Immich through nginx (empty for root)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        locations."${locationPath}" = {
          proxyPass = "http://${config.services.immich.host}:${toString cfg.port}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 0;
            proxy_read_timeout 75s;
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };
      };
    };
  };
}
