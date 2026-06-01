# `dashboard` aspect (Linux/NixOS): the custom `services.homepage-dashboard.nginx`
# reverse-proxy option-module plus the host enabling/settings.
# Combines modules/services/dashboard.nix + system/services/dashboard.nix.
{
  den.aspects.dashboard.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.homepage-dashboard.nginx;

      port = 8082;
    in
    {
      options.services.homepage-dashboard.nginx = {
        enable = lib.mkEnableOption "Enable nginx reverse proxy for homepage-dashboard";

        hostName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Host name to expose homepage-dashboard webui through nginx";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = config.services.homepage-dashboard.listenPort;
          description = "Port to expose homepage-dashboard webui through nginx";
        };

        location = lib.mkOption {
          type = lib.types.str;
          default = "/";
          description = "Location path to expose homepage-dashboard webui through nginx";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          services.nginx = {
            enable = true;

            virtualHosts."${cfg.hostName}" = {
              locations."${cfg.location}" = {
                proxyPass = "http://127.0.0.1:${toString cfg.port}/";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
            };
          };
        })

        # Host config (from system/services/dashboard.nix).
        {
          services.homepage-dashboard = {
            enable = true;
            nginx.enable = true;
            listenPort = port;

            allowedHosts = "*";

            settings = {
              title = "Amadej's Homelab";
            };

            widgets = [
              {
                resources = {
                  cpu = true;
                  disk = "/";
                  memory = true;
                };
              }
            ];

            services = [
              {
                Services = [
                  {
                    Immich = {
                      href = "/immich";
                      icon = "immich";
                    };
                  }
                ];
              }
              {
                Utilities = [
                  {
                    # TODO
                    Traefik = {
                      href = "/traefik";
                      icon = "traefik";
                    };
                  }
                  {
                    Blocky = {
                      href = "/blocky";
                      icon = "blocky";
                    };
                  }
                  {
                    Vaultwarden = {
                      href = "/vaultwarden";
                      icon = "vaultwarden";
                    };
                  }
                ];
              }
              {
                Multimedia = [
                  {
                    Jellyseerr = {
                      icon = "jellyseerr";
                      href = "/jellyseerr";
                    };
                  }
                  {
                    Jellyfin = {
                      icon = "jellyfin";
                      href = "/jellyfin";
                    };
                  }
                  {
                    "Sonarr TV" = {
                      icon = "sonarr";
                      href = "/sonarr";
                    };
                  }
                  {
                    "Sonarr KDrama" = {
                      icon = "sonarr";
                      href = "/sonarr-kdrama";
                    };
                  }
                  {
                    "Sonarr Anime" = {
                      icon = "sonarr";
                      href = "/sonarr-anime";
                    };
                  }
                  {
                    Radarr = {
                      icon = "radarr";
                      href = "/radarr";
                    };
                  }
                  {
                    Bazarr = {
                      icon = "bazarr";
                      href = "/bazarr";
                    };
                  }
                  {
                    Prowlarr = {
                      icon = "prowlarr";
                      href = "/prowlarr";
                    };
                  }
                  {
                    qBittorrent = {
                      icon = "qbittorrent";
                      href = "/qbittorrent";
                    };
                  }
                ];
              }
              {
                Monitoring = [
                  {
                    Prometheus = {
                      href = "/prometheus";
                      icon = "prometheus";
                    };
                  }
                  {
                    Grafana = {
                      href = "/grafana";
                      icon = "grafana";
                    };
                  }
                ];
              }
            ];

            bookmarks = [
              {
                Developer = [
                  {
                    Github = [
                      {
                        icon = "si-github";
                        href = "https://github.com/";
                      }
                    ];
                  }
                  {
                    "Nixos Search" = [
                      {
                        icon = "si-nixos";
                        href = "https://search.nixos.org/packages";
                      }
                    ];
                  }
                  {
                    "Nixos Wiki" = [
                      {
                        icon = "si-nixos";
                        href = "https://nixos.wiki/";
                      }
                    ];
                  }
                ];
              }
            ];
          };
        }
      ];
    };
}
