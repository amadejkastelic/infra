{ config, ... }:
let
  port = 8082;
in
{
  homelab.subdomains = [ "home" ];
  services.homepage-dashboard = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "home.${config.homelab.domain}";
    };
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
              href = "https://immich.${config.homelab.domain}";
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
              href = "https://blocky.${config.homelab.domain}";
              icon = "blocky";
            };
          }
          {
            Vaultwarden = {
              href = "https://vaultwarden.${config.homelab.domain}";
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
              href = "https://jellyseerr.${config.homelab.domain}";
            };
          }
          {
            Jellyfin = {
              icon = "jellyfin";
              href = "https://jellyfin.${config.homelab.domain}";
            };
          }
          {
            "Sonarr TV" = {
              icon = "sonarr";
              href = "https://sonarr.${config.homelab.domain}";
            };
          }
          {
            "Sonarr KDrama" = {
              icon = "sonarr";
              href = "https://sonarr-kdrama.${config.homelab.domain}";
            };
          }
          {
            "Sonarr Anime" = {
              icon = "sonarr";
              href = "https://sonarr-anime.${config.homelab.domain}";
            };
          }
          {
            Radarr = {
              icon = "radarr";
              href = "https://radarr.${config.homelab.domain}";
            };
          }
          {
            Bazarr = {
              icon = "bazarr";
              href = "https://bazarr.${config.homelab.domain}";
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr";
              href = "https://prowlarr.${config.homelab.domain}";
            };
          }
          {
            qBittorrent = {
              icon = "qbittorrent";
              href = "https://qbittorrent.${config.homelab.domain}";
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
              href = "https://grafana.${config.homelab.domain}";
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
