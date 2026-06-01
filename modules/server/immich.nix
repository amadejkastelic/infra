{
  den.aspects.immich.nixos =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    # https://github.com/immich-app/immich/discussions/1679
    # Immich doesn't support a custom urlBase, so we have to expose it with tailscale
    let
      cfg = config.services.immich;
    in
    {
      options.services.immich = {
        tailscale = {
          enable = lib.mkEnableOption "Enable tailscale routing for Immich";

          port = lib.mkOption {
            type = lib.types.int;
            default = 8443;
            description = "Port to expose Immich through tailscale";
          };
        };

        nginx.redirect = {
          enable = lib.mkEnableOption "Enable nginx redirect";

          path = lib.mkOption {
            type = lib.types.str;
            default = "immich";
            description = "Path to redirect from";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = cfg.tailscale.port;
            description = "Port to redirect to";
          };
        };
      };

      config = lib.mkMerge [
        {
          systemd.services.tailscale-serve-immich =
            lib.mkIf (cfg.tailscale.enable && config.services.tailscale.enable)
              {
                description = "Tailscale Serve for Immich";
                after = [
                  "tailscaled.service"
                  "immich-server.service"
                ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  ExecStart = ''
                    ${lib.getExe pkgs.tailscale} serve \
                      --https=${toString cfg.tailscale.port} \
                      --bg http://${config.services.immich.host}:${toString config.services.immich.port}
                  '';
                };
              };

          services.nginx = lib.mkIf cfg.nginx.redirect.enable {
            enable = true;

            virtualHosts."${config.networking.hostName}" = {
              locations."/${cfg.nginx.redirect.path}".extraConfig = ''
                return 301 https://$host:${toString cfg.nginx.redirect.port}/;
              '';
            };
          };
        }

        {
          services.immich = {
            enable = true;
            openFirewall = true;
            machine-learning = {
              enable = true;

              environment = {
                MPLCONFIGDIR = "/var/lib/immich/.config/matplotlib";
              };
            };

            tailscale = {
              enable = true;
              port = 8443;
            };

            nginx.redirect.enable = true;

            port = 2283;

            mediaLocation = "${config.nas.dataDir}/photos";

            database = {
              enable = true;
            };
          };

          users.users."${config.services.immich.user}".extraGroups = [
            "video"
            "render"
          ];

          systemd.tmpfiles.settings."immich" = {
            "${config.services.immich.mediaLocation}".d = {
              user = config.services.immich.user;
              group = config.services.immich.group;
              mode = "0775";
            };
          };
        }
      ];
    };
}
