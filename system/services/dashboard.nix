let
  port = 8082;
in
{
  services.homepage-dashboard = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "home.amadejk.com";
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
              href = "https://immich.amadejk.com";
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
              href = "https://blocky.amadejk.com";
              icon = "blocky";
            };
          }
          {
            Vaultwarden = {
              href = "https://vaultwarden.amadejk.com";
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
              href = "https://jellyseerr.amadejk.com";
            };
          }
          {
            Jellyfin = {
              icon = "jellyfin";
              href = "https://jellyfin.amadejk.com";
            };
          }
          {
            "Sonarr TV" = {
              icon = "sonarr";
              href = "https://sonarr.amadejk.com";
            };
          }
          {
            "Sonarr KDrama" = {
              icon = "sonarr";
              href = "https://sonarr-kdrama.amadejk.com";
            };
          }
          {
            "Sonarr Anime" = {
              icon = "sonarr";
              href = "https://sonarr-anime.amadejk.com";
            };
          }
          {
            Radarr = {
              icon = "radarr";
              href = "https://radarr.amadejk.com";
            };
          }
          {
            Bazarr = {
              icon = "bazarr";
              href = "https://bazarr.amadejk.com";
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr";
              href = "https://prowlarr.amadejk.com";
            };
          }
          {
            qBittorrent = {
              icon = "qbittorrent";
              href = "https://qbittorrent.amadejk.com";
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
