{
  config,
  lib,
  ...
}:

let
  cfg = config.services.vaultwarden.nginx;
  locationPath = if cfg.location == "" then "/" else "/${cfg.location}/";
in
{
  options.services.vaultwarden.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for Vaultwarden";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose vaultwarden webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.vaultwarden.config.rocketPort;
      description = "Port to expose vaultwarden webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location path to expose vaultwarden webui through nginx";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = {
        locations."${locationPath}" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}${locationPath}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
