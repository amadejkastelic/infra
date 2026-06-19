{
  config,
  lib,
  ...
}:

let
  cfg = config.services.blocky.nginx;
  locationPath = if cfg.location == "" then "/" else "/${cfg.location}/";
in
{
  options.services.blocky.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for blocky";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose blocky webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.blocky.settings.ports.http;
      description = "Port to expose blocky webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location path to expose blocky webui through nginx";
    };
  };

  config = lib.mkIf cfg.enable {
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
