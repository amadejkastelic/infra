# `grafana` aspect (Linux/NixOS): the custom `services.grafana.nginx`
# reverse-proxy option-module (sub-path serving + nginx vhost).
# Replaces modules/services/grafana.nix. Host enabling lives in the `metrics` aspect.
{
  den.aspects.grafana.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.grafana.nginx;
    in
    {
      options.services.grafana.nginx = {
        enable = lib.mkEnableOption "Enable nginx reverse proxy for grafana";

        hostName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Host name to expose grafana webui through nginx";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = config.services.grafana.settings.server.http_port;
          description = "Port to expose grafana webui through nginx";
        };

        location = lib.mkOption {
          type = lib.types.str;
          default = "grafana";
          description = "Location path to expose grafana webui through nginx";
        };
      };

      config = lib.mkIf cfg.enable {
        services.grafana.settings.server = {
          root_url = "%(protocol)s://%(domain)s:%(http_port)s/${cfg.location}/";
          serve_from_sub_path = true;
        };

        services.nginx = {
          enable = true;

          virtualHosts."${cfg.hostName}" = {
            locations."/${cfg.location}/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.port}/";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
}
