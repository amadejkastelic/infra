{
  config,
  pkgs,
  self,
  ...
}:
let
  port = 8123;
in
{
  homelab.subdomains = [ "home" ];

  services.home-assistant = {
    enable = true;
    extraComponents = [ "mqtt" ];
    customComponents = with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      homeassistant-mojelektro
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      apexcharts-card
      card-mod
      valetudo-map-card
    ];

    config = {
      default_config = { };
      homeassistant = {
        name = "Home";
        external_url = "https://home.${config.homelab.domain}";
        internal_url = "https://home.${config.homelab.domain}";
        unit_system = "metric";
      };
      http = {
        server_host = "127.0.0.1";
        server_port = port;
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
    };

    lovelaceConfig = {
      title = "Home";
      views = [
        {
          title = "Vacuum";
          path = "vacuum";
          icon = "mdi:robot-vacuum";
          cards = [
            {
              type = "vertical-stack";
              cards = [
                {
                  type = "custom:valetudo-map-card";
                  vacuum = "valetudo_verifiableaggressivelocust";
                }
                {
                  type = "entities";
                  entities = [ "vacuum.valetudo_verifiableaggressivelocust" ];
                }
              ];
            }
          ];
        }
        {
          title = "Electricity";
          path = "electricity";
          icon = "mdi:transmission-tower";
          cards = [
            (import ./cards/mojelektro-daily.nix)
            (import ./cards/mojelektro-15min.nix)
          ];
        }
      ];
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        address = "0.0.0.0";
        users = {
          home-assistant = {
            passwordFile = config.sops.secrets."mqtt/home-assistant-password".path;
            acl = [ "readwrite #" ];
          };
          valetudo = {
            passwordFile = config.sops.secrets."mqtt/valetudo-password".path;
            acl = [
              "readwrite valetudo/#"
              "read homeassistant/status"
              "write homeassistant/#"
            ];
          };
        };
      }
    ];
  };

  services.nginx.virtualHosts."home.${config.homelab.domain}".locations."/" = {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    recommendedProxySettings = true;
    extraConfig = ''
      proxy_buffering off;
    '';
  };

  systemd.services.home-assistant = {
    after = [ "mosquitto.service" ];
    wants = [ "mosquitto.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];

  sops.secrets = {
    "mqtt/home-assistant-password" = { };
    "mqtt/valetudo-password" = { };
  };
}
