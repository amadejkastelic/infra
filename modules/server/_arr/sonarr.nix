{
  config,
  lib,
  pkgs,
  ...
}:

let
  nginxCfg = config.services.sonarr.nginx;
  apiCfg = config.services.sonarr.apiConfig;
  apiConfigurator = import ./api-configurator.nix { inherit lib pkgs config; };

  hostConfig = {
    inherit (config.services.sonarr.settings.server) port;
    urlBase = if nginxCfg.enable then "/${nginxCfg.location}" else "";
    passwordPath = apiCfg.hostPasswordPath;
    instanceName = "Sonarr";
  };
in
{
  options.services.sonarr.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for sonarr";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose sonarr webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = config.services.sonarr.settings.server.port;
      description = "Port to expose sonarr webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "sonarr";
      description = "Location path to expose sonarr webui through nginx";
    };
  };

  options.services.sonarr.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration for sonarr";

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
              description = "Path to the root folder";
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
              description = "Name of the download client";
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
    services.sonarr.settings.server.urlbase = "/${nginxCfg.location}";

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
        sonarr.serviceConfig.LoadCredential = [ "api_key:${config.services.sonarr.apiConfig.apiKeyPath}" ];

        sonarr.preStart = ''
          config_file="${config.services.sonarr.dataDir}/config.xml"
          if [ -f "$config_file" ]; then
            sed -i "s|<Port>.*</Port>|<Port>${toString config.services.sonarr.settings.server.port}</Port>|g" "$config_file"
            sed -i "s|<UrlBase>.*</UrlBase>|<UrlBase>${
              config.services.sonarr.settings.server.urlbase or ""
            }</UrlBase>|g" "$config_file"
            sed -i "s|<ApiKey>.*</ApiKey>|<ApiKey>$(cat $CREDENTIALS_DIRECTORY/api_key)</ApiKey>|g" "$config_file"
          fi
        '';
      }
      (lib.mkIf apiCfg.enable {
        sonarr-config-host = apiConfigurator.mkHostConfigService "sonarr" {
          inherit (apiCfg) apiKeyPath;
          inherit hostConfig;
          apiVersion = "v3";
        };

        sonarr-config-rootfolders = lib.mkIf (apiCfg.rootFolders != [ ]) (
          apiConfigurator.mkRootFoldersService "sonarr" {
            inherit (apiCfg) apiKeyPath rootFolders;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );

        sonarr-config-downloadclients = lib.mkIf (apiCfg.downloadClients != [ ]) (
          apiConfigurator.mkDownloadClientsService "sonarr" {
            inherit (apiCfg) apiKeyPath downloadClients;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );
      })
    ];

    users.users = lib.mkIf (config.services.sonarr.user == "sonarr") {
      sonarr = {
        group = config.services.sonarr.group;
        extraGroups = [ "media" ];
        home = config.services.sonarr.dataDir;
        isSystemUser = true;
      };
    };
  };
}
