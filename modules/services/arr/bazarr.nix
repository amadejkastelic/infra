{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.bazarr;
  nginxCfg = cfg.nginx;
  apiCfg = cfg.apiConfig;
  bazarrConfigurator = import ./bazarr-configurator.nix { inherit lib pkgs; };
  locationPath = if nginxCfg.location == "" then "/" else "/${nginxCfg.location}/";
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
      default = config.services.bazarr.settings.general.port;
      description = "Port to expose bazarr webui through nginx";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Location path to expose bazarr webui through nginx";
    };
  };

  options.services.bazarr.apiConfig = bazarrConfigurator.apiConfigOptions;

  config = lib.mkIf cfg.enable {
    services.bazarr.package = lib.mkDefault bazarrConfigurator.package;

    services.nginx = lib.mkIf nginxCfg.enable {
      enable = true;

      virtualHosts."${nginxCfg.hostName}" = {
        locations."${locationPath}" = {
          proxyPass = "http://127.0.0.1:${toString nginxCfg.port}${locationPath}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };

    systemd.services = lib.mkIf apiCfg.enable {
      bazarr = {
        path = [ pkgs.ffmpeg ];

        serviceConfig.LoadCredential = [ "api_key:${apiCfg.apiKeyPath}" ];

        preStart = bazarrConfigurator.mkPreStart {
          inherit (cfg) dataDir;
          port = cfg.settings.general.port;
          urlBase = cfg.urlBase;
        };
      };

      bazarr-config-settings = bazarrConfigurator.mkSettingsService {
        serviceName = "bazarr";
        port = cfg.settings.general.port;
        urlBase = cfg.urlBase;
        apiConfig = apiCfg;
      };

      bazarr-config-jellyfin = lib.mkIf (apiCfg.jellyfin != null) (
        bazarrConfigurator.mkJellyfinService {
          serviceName = "bazarr";
          port = cfg.settings.general.port;
          urlBase = cfg.urlBase;
          apiConfig = apiCfg;
        }
      );
    };

    users.users = lib.mkIf (config.services.bazarr.user == "bazarr") {
      bazarr = {
        group = config.services.bazarr.group;
        extraGroups = [ "media" ];
        home = config.services.bazarr.dataDir;
        isSystemUser = true;
      };
    };

    assertions = bazarrConfigurator.mkProviderAssertions apiCfg;
  };
}
