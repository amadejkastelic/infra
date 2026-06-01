{
  config,
  lib,
  ...
}:

let
  nginxCfg = config.services.bazarr.nginx;
in
{
  options.services.bazarr.urlBase = lib.mkOption {
    type = lib.types.str;
    default = "/bazarr";
    description = "URL base for bazarr when behind reverse proxy";
  };

  options.services.bazarr.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for bazarr";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose bazarr webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.bazarr.listenPort;
      description = "Port to expose bazarr webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
      description = "Location path to expose bazarr webui through nginx";
    };
  };

  options.services.bazarr.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration for bazarr";

    apiKeyPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to API key secret file";
    };

    hostPasswordPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to host password secret file (optional for external auth)";
    };

    instances = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Display name of instance";
            };
            implementation = lib.mkOption {
              type = lib.types.enum [
                "Sonarr"
                "Radarr"
              ];
              description = "Implementation type (Sonarr or Radarr)";
            };
            hostname = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Hostname or IP address of instance";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = "Port of instance";
            };
            apiKeyPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to API key of instance";
            };
            baseUrl = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "URL base if instance is behind reverse proxy (e.g., /radarr)";
            };
            ssl = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether instance uses SSL/TLS";
            };
            is_default = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Mark this as the default instance for this implementation";
            };
          };
        }
      );
      default = [ ];
      description = "List of Sonarr/Radarr instances to configure via API";
    };

    languages = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enabled = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "en" ];
            description = "List of enabled language codes";
          };
          series = lib.mkOption {
            type = lib.types.submodule {
              options = {
                languages = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ "en" ];
                  description = "Default languages for series";
                };
                hearingImpaired = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Require hearing-impaired subtitles for series";
                };
                forced = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Forced subtitles setting for series";
                };
              };
            };
          };
          movies = lib.mkOption {
            type = lib.types.submodule {
              options = {
                languages = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ "en" ];
                  description = "Default languages for movies";
                };
                hearingImpaired = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Require hearing-impaired subtitles for movies";
                };
                forced = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Forced subtitles setting for movies";
                };
              };
            };
          };
        };
      };
      default = { };
      description = "Language profile settings";
    };
  };

  config = lib.mkIf nginxCfg.enable {
    services.nginx = {
      enable = true;

      virtualHosts."${nginxCfg.hostName}" = {
        locations."/${nginxCfg.location}/" = {
          proxyPass = "http://127.0.0.1:${toString nginxCfg.port}/${nginxCfg.location}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };

    systemd.services = lib.mkMerge [
      {
        bazarr.serviceConfig.LoadCredential = [ "api_key:${config.services.bazarr.apiConfig.apiKeyPath}" ];

        bazarr.preStart = ''
                    config_dir="${config.services.bazarr.dataDir}/config"
                    config_yaml="$config_dir/config.yaml"

                    mkdir -p "$config_dir"

                    if [ ! -f "$config_yaml" ]; then
                      cat > "$config_yaml" <<'EOF'
          general:
            base_url: /bazarr
            port: ${toString config.services.bazarr.listenPort}
          api_key: $(cat $CREDENTIALS_DIRECTORY/api_key)
          EOF
                    fi

                    sed -i "s|^general:.*|general:|g; s|^  base_url:.*|  base_url:|g" "$config_yaml"
                    sed -i "s|^  base_url:.*|  base_url: ${config.services.bazarr.urlBase}|g" "$config_yaml"
                    sed -i "s|^  port:.*|  port: ${toString config.services.bazarr.listenPort}|g" "$config_yaml"
                    sed -i "s|^api_key:.*|api_key: $(cat $CREDENTIALS_DIRECTORY/api_key)|g" "$config_yaml"
        '';
      }

    ];

    users.users = lib.mkIf (config.services.bazarr.user == "bazarr") {
      bazarr = {
        group = config.services.bazarr.group;
        extraGroups = [ "media" ];
        home = config.services.bazarr.dataDir;
        isSystemUser = true;
      };
    };
  };
}
