{
  config,
  lib,
  ...
}:

let
  port = 8082;

  site =
    title: sub: icon: altStatusCodes:
    {
      inherit title icon;
      url = "https://${sub}.${config.homelab.domain}";
    }
    // lib.optionalAttrs (altStatusCodes != null) { alt-status-codes = altStatusCodes; };
in
{
  homelab.subdomains = [ "dashboard" ];

  services.glance = {
    enable = true;

    nginx = {
      enable = true;
      hostName = "dashboard.${config.homelab.domain}";
    };

    settings = {
      server = {
        host = "127.0.0.1";
        inherit port;
      };

      theme = {
        background-color = "240 21 15";
        contrast-multiplier = 1.2;
        primary-color = "267 84 81";
        positive-color = "142 76 36";
        negative-color = "343 81 59";
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "clock";
                  hour-format = "24h";
                }
                {
                  type = "weather";
                  location = "Ljubljana, Slovenia";
                  units = "metric";
                  hour-format = "24h";
                }
                {
                  type = "server-stats";
                  servers = [
                    {
                      type = "local";
                      name = "razer";
                    }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Developer";
                      links = [
                        {
                          title = "GitHub";
                          url = "https://github.com/";
                          icon = "si:github";
                        }
                        {
                          title = "Website";
                          url = "https://amadejk.com";
                          icon = "di:firefox";
                        }
                        {
                          title = "NixOS Search";
                          url = "https://search.nixos.org/packages";
                          icon = "si:nixos";
                        }
                        {
                          title = "NixOS Wiki";
                          url = "https://nixos.wiki/";
                          icon = "si:nixos";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "monitor";
                  title = "Services";
                  sites = [
                    (site "Home Assistant" "home" "di:home-assistant" null)
                    (site "Immich" "immich" "di:immich" [ 302 ])
                  ];
                }
                {
                  type = "monitor";
                  title = "Utilities";
                  sites = [
                    {
                      title = "Blocky";
                      url = "https://blocky.${config.homelab.domain}";
                      check-url = "https://blocky.${config.homelab.domain}/metrics";
                      icon = "di:blocky";
                    }
                    (site "Vaultwarden" "vaultwarden" "di:vaultwarden" null)
                  ];
                }
                {
                  type = "monitor";
                  title = "Multimedia";
                  style = "compact";
                  sites = [
                    (site "Jellyseerr" "jellyseerr" "di:jellyseerr" [ 302 ])
                    (site "Jellyfin" "jellyfin" "di:jellyfin" [ 302 ])
                    (site "Sonarr TV" "sonarr" "di:sonarr" [ 302 ])
                    (site "Sonarr KDrama" "sonarr-kdrama" "di:sonarr" [ 302 ])
                    (site "Sonarr Anime" "sonarr-anime" "di:sonarr" [ 302 ])
                    (site "Radarr" "radarr" "di:radarr" [ 302 ])
                    (site "Bazarr" "bazarr" "di:bazarr" [ 302 ])
                    (site "Bazarr KDrama" "bazarr-kdrama" "di:bazarr" [ 302 ])
                    (site "Prowlarr" "prowlarr" "di:prowlarr" [ 302 ])
                    (site "qBittorrent" "qbittorrent" "di:qbittorrent" null)
                  ];
                }
                {
                  type = "monitor";
                  title = "Developer";
                  sites = [
                    (site "Forgejo" "git" "di:forgejo" null)
                    (site "CloudCLI" "vibe" "di:claude-ai" null)
                  ];
                }
                {
                  type = "monitor";
                  title = "Monitoring";
                  sites = [ (site "Grafana" "grafana" "di:grafana" [ 302 ]) ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
