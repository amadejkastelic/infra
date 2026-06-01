{
  den.aspects.vaultwarden.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.vaultwarden.nginx;
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
          default = "vaultwarden";
          description = "Location path to expose vaultwarden webui through nginx";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          services.nginx = {
            enable = true;

            virtualHosts."${cfg.hostName}" = {
              locations."/${cfg.location}/" = {
                proxyPass = "http://127.0.0.1:${toString cfg.port}/vaultwarden/";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
            };
          };
        })

        {
          services.vaultwarden = {
            enable = true;
            nginx.enable = true;

            environmentFile = config.sops.secrets.vaultwarden-env.path;

            dbBackend = "sqlite";
            backupDir = "${config.nas.backupDir}/vaultwarden/";

            config = {
              domain = "http://${config.networking.hostName}/vaultwarden";
              signupsAllowed = false;
              showPasswordHint = false;

              rocketAddress = "127.0.0.1";
              rocketPort = 8222;
              rocketLog = "critical";
            };
          };

          sops.secrets.vaultwarden-env =
            let
              serviceConfig = config.systemd.services.vaultwarden.serviceConfig;
            in
            {
              owner = serviceConfig.User;
              group = serviceConfig.Group;
            };
        }
      ];
    };
}
