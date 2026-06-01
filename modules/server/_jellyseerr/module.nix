{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seerr;
  nginxCfg = cfg.nginx;
in

{
  imports = [
    ./nginx.nix
    ./setup.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  options.services.seerr = {
    nginx = {
      enable = lib.mkEnableOption "nginx reverse proxy for Jellyseerr";

      hostName = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
        description = "Host name to expose Jellyseerr webui through nginx";
      };

      location = lib.mkOption {
        type = lib.types.str;
        default = "jellyseerr";
        description = "Location path to expose Jellyseerr webui through nginx";
      };
    };

    jellyfin = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Jellyfin server hostname";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8096;
        description = "Jellyfin server port";
      };

      urlBase = lib.mkOption {
        type = lib.types.str;
        default = "jellyfin";
        description = "Jellyfin URL base path";
      };

      useSsl = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether Jellyfin uses SSL";
      };

      serverType = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Jellyfin server type (2 = Jellyfin, 3 = Emby)";
      };

      enableAllLibraries = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable all Jellyfin libraries";
      };
    };

    radarr = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the Radarr instance";
            };

            hostname = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Radarr server hostname";
            };

            port = lib.mkOption {
              type = lib.types.port;
              description = "Radarr server port";
            };

            apiKeyPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to the Radarr API key secret file";
            };

            baseUrl = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Radarr URL base path";
            };

            useSsl = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether Radarr uses SSL";
            };

            isDefault = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is the default Radarr instance";
            };

            is4k = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is the 4K Radarr instance";
            };

            activeDirectory = lib.mkOption {
              type = lib.types.str;
              description = "Root folder for this Radarr instance";
            };

            activeProfileName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Quality profile name to use (null = auto-select first)";
            };

            minimumAvailability = lib.mkOption {
              type = lib.types.str;
              default = "released";
              description = "Minimum availability for movies";
            };

            externalUrl = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "External URL for this Radarr instance";
            };

            syncEnabled = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable syncing with Radarr";
            };

            preventSearch = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Prevent automatic search when adding movies";
            };
          };
        }
      );
      default = [ ];
      description = "List of Radarr instances to configure";
    };

    sonarr = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the Sonarr instance";
            };

            hostname = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Sonarr server hostname";
            };

            port = lib.mkOption {
              type = lib.types.port;
              description = "Sonarr server port";
            };

            apiKeyPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to the Sonarr API key secret file";
            };

            baseUrl = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Sonarr URL base path";
            };

            useSsl = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether Sonarr uses SSL";
            };

            isDefault = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is the default Sonarr instance";
            };

            is4k = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is the 4K Sonarr instance";
            };

            activeDirectory = lib.mkOption {
              type = lib.types.str;
              description = "Root folder for this Sonarr instance";
            };

            activeProfileName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Quality profile name to use (null = auto-select first)";
            };

            activeAnimeDirectory = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Root folder for anime (if different from main)";
            };

            activeAnimeProfileName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Quality profile name for anime (null = use regular profile)";
            };

            seriesType = lib.mkOption {
              type = lib.types.str;
              default = "standard";
              description = "Series type (standard, daily, anime)";
            };

            animeSeriesType = lib.mkOption {
              type = lib.types.str;
              default = "anime";
              description = "Series type for anime";
            };

            enableSeasonFolders = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable season folders";
            };

            externalUrl = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "External URL for this Sonarr instance";
            };

            syncEnabled = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Enable syncing with Sonarr";
            };

            preventSearch = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Prevent automatic search when adding series";
            };
          };
        }
      );
      default = [ ];
      description = "List of Sonarr instances to configure";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.length (lib.filter (r: r.isDefault) cfg.radarr) <= 1;
        message = "Cannot have more than 1 default Radarr instance in jellyseerr.radarr";
      }
      {
        assertion = lib.length (lib.filter (s: s.isDefault) cfg.sonarr) <= 1;
        message = "Cannot have more than 1 default Sonarr instance in jellyseerr.sonarr";
      }
    ];
  };
}
