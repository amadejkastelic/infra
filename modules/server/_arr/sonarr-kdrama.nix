{
  config,
  lib,
  pkgs,
  ...
}:

let
  nginxCfg = config.services.sonarr-kdrama.nginx;
  apiCfg = config.services.sonarr-kdrama.apiConfig;
  apiConfigurator = import ./api-configurator.nix { inherit lib pkgs config; };

  hostConfig = {
    inherit (config.services.sonarr-kdrama.settings.server) port;
    urlBase = if nginxCfg.enable then "/${nginxCfg.location}" else "";
    passwordPath = apiCfg.hostPasswordPath;
    instanceName = "Sonarr KDrama";
  };
in
{
  options.services.sonarr-kdrama.enable = lib.mkEnableOption "Sonarr KDrama service";
  options.services.sonarr-kdrama.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.sonarr;
    description = "Sonarr package to use";
  };

  options.services.sonarr-kdrama.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/sonarr-kdrama";
    description = "The directory where Sonarr KDrama stores its data files.";
  };

  options.services.sonarr-kdrama.user = lib.mkOption {
    type = lib.types.str;
    default = "sonarr-kdrama";
    description = "User account under which Sonarr KDrama runs.";
  };

  options.services.sonarr-kdrama.group = lib.mkOption {
    type = lib.types.str;
    default = "sonarr-kdrama";
    description = "Group account under which Sonarr KDrama runs.";
  };

  options.services.sonarr-kdrama.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for sonarr-kdrama";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose sonarr-kdrama webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8991;
      description = "Port to expose sonarr-kdrama webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "sonarr-kdrama";
      description = "Location path to expose sonarr-kdrama webui through nginx";
    };
  };

  options.services.sonarr-kdrama.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration for sonarr-kdrama";

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

  options.services.sonarr-kdrama.settings = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    description = "Sonarr KDrama settings. See https://wiki.servarr.com/sonarr";
  };

  config = lib.mkIf config.services.sonarr-kdrama.enable {
    services.sonarr-kdrama.settings.server.urlbase = lib.mkIf nginxCfg.enable "/${nginxCfg.location}";
    systemd.tmpfiles.settings."10-sonarr-kdrama".${config.services.sonarr-kdrama.dataDir}.d = {
      inherit (config.services.sonarr-kdrama) user group;
      mode = "0700";
    };

    systemd.services = lib.mkMerge [
      {
        sonarr-kdrama = {
          description = "Sonarr KDrama";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          environment =
            lib.mapAttrs'
              (name: value: {
                name = lib.toUpper "SONARR__${name}";
                value = builtins.toString value;
              })
              (lib.filterAttrs (name: value: !(builtins.isAttrs value)) config.services.sonarr-kdrama.settings);

          serviceConfig = {
            Type = "simple";
            User = config.services.sonarr-kdrama.user;
            Group = config.services.sonarr-kdrama.group;
            ExecStart = "${config.services.sonarr-kdrama.package}/bin/Sonarr -nobrowser -data='${config.services.sonarr-kdrama.dataDir}'";
            Restart = "on-failure";
            LoadCredential = [ "api_key:${config.services.sonarr-kdrama.apiConfig.apiKeyPath}" ];
          };

          preStart = ''
            config_file="${config.services.sonarr-kdrama.dataDir}/config.xml"
            if [ -f "$config_file" ]; then
              sed -i "s|<Port>.*</Port>|<Port>${toString config.services.sonarr-kdrama.settings.server.port}</Port>|g" "$config_file"
              sed -i "s|<UrlBase>.*</UrlBase>|<UrlBase>${
                config.services.sonarr-kdrama.settings.server.urlbase or ""
              }</UrlBase>|g" "$config_file"
              sed -i "s|<ApiKey>.*</ApiKey>|<ApiKey>$(cat $CREDENTIALS_DIRECTORY/api_key)</ApiKey>|g" "$config_file"
              ${lib.optionalString (config.services.sonarr-kdrama.settings ? auth) ''
                sed -i "s|<AuthenticationMethod>.*</AuthenticationMethod>|<AuthenticationMethod>${config.services.sonarr-kdrama.settings.auth.authenticationMethod}</AuthenticationMethod>|g" "$config_file"
                sed -i "s|<AuthenticationRequired>.*</AuthenticationRequired>|<AuthenticationRequired>${config.services.sonarr-kdrama.settings.auth.authenticationRequired}</AuthenticationRequired>|g" "$config_file"
              ''}
            fi
          '';
        };
      }
      (lib.mkIf apiCfg.enable {
        sonarr-kdrama-config-host = apiConfigurator.mkHostConfigService "sonarr-kdrama" {
          inherit (apiCfg) apiKeyPath;
          inherit hostConfig;
          apiVersion = "v3";
        };

        sonarr-kdrama-config-rootfolders = lib.mkIf (apiCfg.rootFolders != [ ]) (
          apiConfigurator.mkRootFoldersService "sonarr-kdrama" {
            inherit (apiCfg) apiKeyPath rootFolders;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );

        sonarr-kdrama-config-downloadclients = lib.mkIf (apiCfg.downloadClients != [ ]) (
          apiConfigurator.mkDownloadClientsService "sonarr-kdrama" {
            inherit (apiCfg) apiKeyPath downloadClients;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );
      })
    ];

    users.users = lib.mkIf (config.services.sonarr-kdrama.user == "sonarr-kdrama") {
      sonarr-kdrama = {
        group = config.services.sonarr-kdrama.group;
        extraGroups = [ "media" ];
        home = config.services.sonarr-kdrama.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (config.services.sonarr-kdrama.group == "sonarr-kdrama") {
      sonarr-kdrama = { };
    };

    services.nginx = lib.mkIf nginxCfg.enable {
      enable = true;

      virtualHosts."${nginxCfg.hostName}" = {
        locations."/${nginxCfg.location}/" = {
          proxyPass = "http://127.0.0.1:${toString nginxCfg.port}/${nginxCfg.location}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
