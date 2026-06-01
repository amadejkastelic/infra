{
  config,
  lib,
  pkgs,
  ...
}:

let
  nginxCfg = config.services.radarr.nginx;
  apiCfg = config.services.radarr.apiConfig;
  apiConfigurator = import ./api-configurator.nix { inherit lib pkgs config; };

  hostConfig = {
    inherit (config.services.radarr.settings.server) port;
    urlBase = if nginxCfg.enable then "/${nginxCfg.location}" else "";
    passwordPath = apiCfg.hostPasswordPath;
    instanceName = "Radarr";
  };
in
{
  options.services.radarr.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for radarr";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose radarr webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.radarr.settings.server.port;
      description = "Port to expose radarr webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "radarr";
      description = "Location path to expose radarr webui through nginx";
    };
  };

  options.services.radarr.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration for radarr";

    apiKeyPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to API key secret file";
    };

    hostPasswordPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to host password secret file (optional for external auth)";
    };

    rootFolders = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.path;
              description = "Path to root folder";
            };
          };
        }
      );
      default = [ ];
      description = "List of root folders to configure via API";
    };

    downloadClients = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of download client";
            };
            implementationName = lib.mkOption {
              type = lib.types.str;
              description = "Download client implementation (e.g., qBittorrent)";
            };
            apiKeyPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to download client API key secret file";
            };
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Download client host";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = "Download client port";
            };
            category = lib.mkOption {
              type = lib.types.str;
              description = "Download client category";
            };
            importMode = lib.mkOption {
              type = lib.types.str;
              default = "copy";
              description = "Import mode (copy, move, hardlink)";
            };
          };
        }
      );
      default = [ ];
      description = "List of download clients to configure via API";
    };
  };

  config = lib.mkIf nginxCfg.enable {
    services.radarr.settings.server.urlbase = "/${nginxCfg.location}";

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
        radarr.serviceConfig.LoadCredential = [ "api_key:${config.services.radarr.apiConfig.apiKeyPath}" ];

        radarr.preStart = ''
          config_file="${config.services.radarr.dataDir}/config.xml"
          if [ -f "$config_file" ]; then
            sed -i "s|<Port>.*</Port>|<Port>${toString config.services.radarr.settings.server.port}</Port>|g" "$config_file"
            sed -i "s|<UrlBase>.*</UrlBase>|<UrlBase>${
              config.services.radarr.settings.server.urlbase or ""
            }</UrlBase>|g" "$config_file"
            sed -i "s|<ApiKey>.*</ApiKey>|<ApiKey>$(cat $CREDENTIALS_DIRECTORY/api_key)</ApiKey>|g" "$config_file"
          fi
        '';
      }
      (lib.mkIf apiCfg.enable {
        radarr-config-host = apiConfigurator.mkHostConfigService "radarr" {
          inherit (apiCfg) apiKeyPath;
          inherit hostConfig;
          apiVersion = "v3";
        };

        radarr-config-rootfolders = lib.mkIf (apiCfg.rootFolders != [ ]) (
          apiConfigurator.mkRootFoldersService "radarr" {
            inherit (apiCfg) apiKeyPath rootFolders;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );

        radarr-config-downloadclients = lib.mkIf (apiCfg.downloadClients != [ ]) (
          apiConfigurator.mkDownloadClientsService "radarr" {
            inherit (apiCfg) apiKeyPath downloadClients;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );
      })
    ];

    users.users = lib.mkIf (config.services.radarr.user == "radarr") {
      radarr = {
        group = config.services.radarr.group;
        extraGroups = [ "media" ];
        home = config.services.radarr.dataDir;
        isSystemUser = true;
      };
    };
  };
}
