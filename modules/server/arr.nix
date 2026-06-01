# `arr` aspect (Linux/NixOS): the full *arr media-automation stack — the custom
# option-modules for bazarr / prowlarr / radarr / sonarr / sonarr-anime /
# sonarr-kdrama (nginx reverse proxies + declarative API configuration) plus the
# host enabling/settings for each.
#
# Combines modules/services/arr/* (option-modules, imported as sibling assets in
# ./_arr/) with system/services/arr/{bazarr,prowlarr,radarr,sonarr,sonarr-anime,
# sonarr-kdrama}.nix (consumers). flaresolverr, qbittorrent and jellyseerr are
# their own aspects.
{
  den.aspects.arr.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mediaDir = config.nas.mediaDir;
    in
    {
      imports = [
        ./_arr/bazarr.nix
        ./_arr/prowlarr.nix
        ./_arr/radarr.nix
        ./_arr/sonarr.nix
        ./_arr/sonarr-anime.nix
        ./_arr/sonarr-kdrama.nix
      ];

      # ---- bazarr (system/services/arr/bazarr.nix) ----
      services.bazarr = {
        enable = true;
        nginx.enable = true;
        listenPort = 6767;

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."bazarr/api_key".path;

          instances = [
            {
              name = "Radarr";
              implementation = "Radarr";
              hostname = "127.0.0.1";
              port = 7878;
              apiKeyPath = config.sops.secrets."radarr/api_key".path;
              baseUrl = "/radarr";
              is_default = true;
            }
            {
              name = "Sonarr TV";
              implementation = "Sonarr";
              hostname = "127.0.0.1";
              port = 8989;
              apiKeyPath = config.sops.secrets."sonarr/api_key".path;
              baseUrl = "/sonarr";
            }
            {
              name = "Sonarr Anime";
              implementation = "Sonarr";
              hostname = "127.0.0.1";
              port = 8990;
              apiKeyPath = config.sops.secrets."sonarr-anime/api_key".path;
              baseUrl = "/sonarr-anime";
            }
            {
              name = "Sonarr KDrama";
              implementation = "Sonarr";
              hostname = "127.0.0.1";
              port = 8991;
              apiKeyPath = config.sops.secrets."sonarr-kdrama/api_key".path;
              baseUrl = "/sonarr-kdrama";
            }
          ];

          languages = {
            enabled = [ "en" ];
            series = {
              languages = [ "en" ];
              hearingImpaired = false;
              forced = false;
            };
            movies = {
              languages = [ "en" ];
              hearingImpaired = false;
              forced = false;
            };
          };
        };
      };

      # ---- prowlarr (system/services/arr/prowlarr.nix) ----
      services.prowlarr = {
        enable = true;

        nginx.enable = true;

        settings = {
          log.analyticsEnabled = false;
          update.automatically = false;
          server.port = 9696;
        };

        environmentFiles = [
          (pkgs.writeText "prowlarr.env" ''
            PROWLARR__AUTH__METHOD=External
            PROWLARR__AUTH__REQUIRED=DisabledForLocalAddresses
          '')
        ];

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."prowlarr/api_key".path;

          indexerProxies = lib.optional config.services.flaresolverr.enable {
            name = "FlareSolverr";
            implementation = "FlareSolverr";
            hostUrl = "http://127.0.0.1:${toString config.services.flaresolverr.port}";
            requestTimeout = 60;
            tags = [ "cloudflare" ];
          };

          # Names (case sensitive) should match the ones in prowlarr
          indexers = [
            {
              name = "YTS";
              tags = [ "movies" ];
            }
            {
              name = "Nyaa.si";
              tags = [ "anime" ];
            }
            {
              name = "SubsPlease";
              tags = [ "anime" ];
            }
            {
              name = "Infire";
              credentialsPaths = [
                {
                  baseName = "username";
                  path = config.sops.secrets."infire/username".path;
                }
                {
                  baseName = "password";
                  path = config.sops.secrets."infire/password".path;
                }
              ];
              tags = [
                "movies"
                "tv"
              ];
            }
          ]
          ++ lib.optionals config.services.flaresolverr.enable [
            {
              name = "1337x";
              tags = [
                "movies"
                "tv"
                "cloudflare"
              ];
            }
            {
              name = "AvistaZ";
              credentialsPaths = [
                {
                  baseName = "username";
                  path = config.sops.secrets."avistaz/username".path;
                }
                {
                  baseName = "password";
                  path = config.sops.secrets."avistaz/password".path;
                }
                {
                  baseName = "pid";
                  path = config.sops.secrets."avistaz/pid".path;
                }
              ];
              tags = [
                "kdrama"
                "cloudflare"
              ];
            }
          ];
        };
      };

      # ---- radarr (system/services/arr/radarr.nix) ----
      services.radarr = {
        enable = true;
        nginx.enable = true;

        settings = {
          log.analyticsEnabled = false;
          update.automatically = false;
          server.port = 7878;
          auth = {
            authenticationMethod = "External";
            authenticationRequired = "DisabledForLocalAddresses";
          };
        };

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."radarr/api_key".path;
          rootFolders = [
            { path = "${mediaDir}/movies"; }
          ];
          downloadClients = [
            {
              name = "qBittorrent";
              implementationName = "qBittorrent";
              host = "127.0.0.1";
              port = 8088;
              apiKeyPath = config.sops.secrets."qbittorrent/api_key".path;
              category = "movies";
              importMode = "hardlink";
            }
          ];
        };
      };

      # ---- sonarr (system/services/arr/sonarr.nix) ----
      services.sonarr = {
        enable = true;

        nginx.enable = true;

        settings = {
          log.analyticsEnabled = false;
          update.automatically = false;
          server.port = 8989;
          auth = {
            authenticationMethod = "External";
            authenticationRequired = "DisabledForLocalAddresses";
          };
        };

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."sonarr/api_key".path;
          rootFolders = [
            { path = "${mediaDir}/tv"; }
          ];
          downloadClients = [
            {
              name = "qBittorrent";
              implementationName = "qBittorrent";
              host = "127.0.0.1";
              port = 8088;
              apiKeyPath = config.sops.secrets."qbittorrent/api_key".path;
              category = "tv";
              importMode = "hardlink";
            }
          ];
        };
      };

      # ---- sonarr-anime (system/services/arr/sonarr-anime.nix) ----
      services.sonarr-anime = {
        enable = true;
        nginx.enable = true;

        settings = {
          log.analyticsEnabled = false;
          update.automatically = false;
          server.port = 8990;
          auth = {
            authenticationMethod = "External";
            authenticationRequired = "DisabledForLocalAddresses";
          };
        };

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."sonarr-anime/api_key".path;
          rootFolders = [
            { path = "${mediaDir}/anime"; }
          ];
          downloadClients = [
            {
              name = "qBittorrent";
              implementationName = "qBittorrent";
              host = "127.0.0.1";
              port = 8088;
              apiKeyPath = config.sops.secrets."qbittorrent/api_key".path;
              category = "anime";
              importMode = "hardlink";
            }
          ];
        };
      };

      # ---- sonarr-kdrama (system/services/arr/sonarr-kdrama.nix) ----
      services.sonarr-kdrama = {
        enable = true;
        nginx.enable = true;

        settings = {
          log.analyticsEnabled = false;
          update.automatically = false;
          server.port = 8991;
          auth = {
            authenticationMethod = "External";
            authenticationRequired = "DisabledForLocalAddresses";
          };
        };

        apiConfig = {
          enable = true;
          apiKeyPath = config.sops.secrets."sonarr-kdrama/api_key".path;
          rootFolders = [
            { path = "${mediaDir}/kdrama"; }
          ];
          downloadClients = [
            {
              name = "qBittorrent";
              implementationName = "qBittorrent";
              host = "127.0.0.1";
              port = 8088;
              apiKeyPath = config.sops.secrets."qbittorrent/api_key".path;
              category = "kdrama";
              importMode = "hardlink";
            }
          ];
        };
      };

      # ---- secrets + tmpfiles (merged from the per-service consumers) ----
      sops.secrets = {
        "bazarr/api_key" = {
          owner = "bazarr";
          group = "bazarr";
        };

        "radarr/api_key" = {
          owner = "radarr";
          group = "radarr";
        };

        "qbittorrent/api_key" = {
          owner = "qbittorrent";
          group = "media";
        };

        "sonarr/api_key" = {
          owner = "sonarr";
          group = "sonarr";
        };

        "sonarr-anime/api_key" = {
          owner = "sonarr-anime";
          group = "sonarr-anime";
        };

        "sonarr-kdrama/api_key" = {
          owner = "sonarr-kdrama";
          group = "sonarr-kdrama";
        };

        "prowlarr/api_key" = { };

        "avistaz/username" = { };
        "avistaz/password" = { };
        "avistaz/pid" = { };

        "infire/username" = { };
        "infire/password" = { };
      };

      systemd.tmpfiles.settings = {
        "radarr"."${mediaDir}/movies".d = {
          user = "radarr";
          group = "media";
          mode = "0775";
        };
        "sonarr"."${mediaDir}/tv".d = {
          user = "sonarr";
          group = "media";
          mode = "0775";
        };
        "sonarr-anime"."${mediaDir}/anime".d = {
          user = "sonarr-anime";
          group = "media";
          mode = "0775";
        };
        "sonarr-kdrama"."${mediaDir}/kdrama".d = {
          user = "sonarr-kdrama";
          group = "media";
          mode = "0775";
        };
      };
    };
}
