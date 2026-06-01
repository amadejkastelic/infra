{
  config,
  lib,
  pkgs,
  ...
}:

let
  nginxCfg = config.services.sonarr-anime.nginx;
  apiCfg = config.services.sonarr-anime.apiConfig;
  apiConfigurator = import ./api-configurator.nix { inherit lib pkgs config; };

  hostConfig = {
    inherit (config.services.sonarr-anime.settings.server) port;
    urlBase = if nginxCfg.enable then "/${nginxCfg.location}" else "";
    passwordPath = apiCfg.hostPasswordPath;
    instanceName = "Sonarr Anime";
  };
in
{
  options.services.sonarr-anime.enable = lib.mkEnableOption "Sonarr Anime service";
  options.services.sonarr-anime.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.sonarr;
    description = "Sonarr package to use";
  };

  options.services.sonarr-anime.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/sonarr-anime";
    description = "The directory where Sonarr Anime stores its data files.";
  };

  options.services.sonarr-anime.user = lib.mkOption {
    type = lib.types.str;
    default = "sonarr-anime";
    description = "User account under which Sonarr Anime runs.";
  };

  options.services.sonarr-anime.group = lib.mkOption {
    type = lib.types.str;
    default = "sonarr-anime";
    description = "Group account under which Sonarr Anime runs.";
  };

  options.services.sonarr-anime.nginx = {
    enable = lib.mkEnableOption "Enable nginx reverse proxy for sonarr-anime";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Host name to expose sonarr-anime webui through nginx";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8990;
      description = "Port to expose sonarr-anime webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "sonarr-anime";
      description = "Location path to expose sonarr-anime webui through nginx";
    };
  };

  options.services.sonarr-anime.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration for sonarr-anime";

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

  options.services.sonarr-anime.settings = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    description = "Sonarr Anime settings. See https://wiki.servarr.com/sonarr";
  };

  config = lib.mkIf config.services.sonarr-anime.enable {
    services.sonarr-anime.settings.server.urlbase = lib.mkIf nginxCfg.enable "/${nginxCfg.location}";
    systemd.tmpfiles.settings."10-sonarr-anime".${config.services.sonarr-anime.dataDir}.d = {
      inherit (config.services.sonarr-anime) user group;
      mode = "0700";
    };

    systemd.services = lib.mkMerge [
      {
        sonarr-anime = {
          description = "Sonarr Anime";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          environment = lib.mapAttrs' (name: value: {
            name = lib.toUpper "SONARR__${name}";
            value = builtins.toString value;
          }) (lib.filterAttrs (name: value: !(builtins.isAttrs value)) config.services.sonarr-anime.settings);

          serviceConfig = {
            Type = "simple";
            User = config.services.sonarr-anime.user;
            Group = config.services.sonarr-anime.group;
            ExecStart = "${config.services.sonarr-anime.package}/bin/Sonarr -nobrowser -data='${config.services.sonarr-anime.dataDir}'";
            Restart = "on-failure";
            LoadCredential = [ "api_key:${config.services.sonarr-anime.apiConfig.apiKeyPath}" ];
          };

          preStart = ''
            config_file="${config.services.sonarr-anime.dataDir}/config.xml"
            if [ -f "$config_file" ]; then
              sed -i "s|<Port>.*</Port>|<Port>${toString config.services.sonarr-anime.settings.server.port}</Port>|g" "$config_file"
              sed -i "s|<UrlBase>.*</UrlBase>|<UrlBase>${
                config.services.sonarr-anime.settings.server.urlbase or ""
              }</UrlBase>|g" "$config_file"
              sed -i "s|<ApiKey>.*</ApiKey>|<ApiKey>$(cat $CREDENTIALS_DIRECTORY/api_key)</ApiKey>|g" "$config_file"
              ${lib.optionalString (config.services.sonarr-anime.settings ? auth) ''
                sed -i "s|<AuthenticationMethod>.*</AuthenticationMethod>|<AuthenticationMethod>${config.services.sonarr-anime.settings.auth.authenticationMethod}</AuthenticationMethod>|g" "$config_file"
                sed -i "s|<AuthenticationRequired>.*</AuthenticationRequired>|<AuthenticationRequired>${config.services.sonarr-anime.settings.auth.authenticationRequired}</AuthenticationRequired>|g" "$config_file"
              ''}
            fi
          '';
        };
      }
      (lib.mkIf apiCfg.enable {
        sonarr-anime-config-host = apiConfigurator.mkHostConfigService "sonarr-anime" {
          inherit (apiCfg) apiKeyPath;
          inherit hostConfig;
          apiVersion = "v3";
        };

        sonarr-anime-config-rootfolders = lib.mkIf (apiCfg.rootFolders != [ ]) (
          apiConfigurator.mkRootFoldersService "sonarr-anime" {
            inherit (apiCfg) apiKeyPath rootFolders;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );

        sonarr-anime-config-downloadclients = lib.mkIf (apiCfg.downloadClients != [ ]) (
          apiConfigurator.mkDownloadClientsService "sonarr-anime" {
            inherit (apiCfg) apiKeyPath downloadClients;
            inherit hostConfig;
            apiVersion = "v3";
          }
        );
      })
    ];

    users.users = lib.mkIf (config.services.sonarr-anime.user == "sonarr-anime") {
      sonarr-anime = {
        group = config.services.sonarr-anime.group;
        extraGroups = [ "media" ];
        home = config.services.sonarr-anime.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (config.services.sonarr-anime.group == "sonarr-anime") {
      sonarr-anime = { };
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
