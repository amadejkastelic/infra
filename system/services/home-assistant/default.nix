{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  port = 8123;

  mojelektroMeters = [ "3-8119417" ];

  electricityView = {
    title = "Electricity";
    path = "electricity";
    icon = "mdi:transmission-tower";
    cards = lib.concatMap (m: [
      (import ./cards/mojelektro-daily.nix m)
      (import ./cards/mojelektro-interval.nix m)
    ]) (map (m: lib.replaceStrings [ "-" ] [ "" ] m) mojelektroMeters);
  };
in
{
  imports = [
    (import ./mojelektro.nix {
      meters = mojelektroMeters;
      inherit port;
    })
  ];

  homelab.subdomains = [ "home" ];

  services.home-assistant = {
    enable = true;
    extraComponents = [ "mqtt" ];
    customComponents = with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      homeassistant-mojelektro-stats
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      valetudo-map-card
    ];

    config = {
      default_config = { };
      homeassistant = {
        name = "Home";
        external_url = "https://home.${config.homelab.domain}";
        internal_url = "https://home.${config.homelab.domain}";
        unit_system = "metric";
        auth_providers = [
          { type = "homeassistant"; }
          {
            type = "trusted_networks";
            trusted_networks = [ "127.0.0.2/32" ];
            allow_bypass_login = true;
          }
        ];
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
      ]
      ++ lib.optional (mojelektroMeters != [ ]) electricityView;
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
