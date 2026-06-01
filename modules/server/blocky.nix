# `blocky` aspect (Linux/NixOS): the custom `services.blocky.nginx` reverse-proxy
# option-module plus the host enabling/settings.
# Combines modules/services/blocky.nix + system/services/blocky.nix.
{
  den.aspects.blocky.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.blocky.nginx;

      dnsServers = [
        "1.1.1.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    in
    {
      options.services.blocky.nginx = {
        enable = lib.mkEnableOption "Enable nginx reverse proxy for blocky";

        hostName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Host name to expose blocky webui through nginx";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = config.services.blocky.settings.ports.http;
          description = "Port to expose blocky webui through nginx";
        };

        location = lib.mkOption {
          type = lib.types.str;
          default = "blocky";
          description = "Location path to expose blocky webui through nginx";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
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
        })

        # Host config (from system/services/blocky.nix).
        {
          networking.nameservers = [ "127.0.0.1" ] ++ dnsServers;

          services.blocky = {
            enable = true;
            nginx.enable = true;

            settings = {
              ports = {
                dns = 53;
                http = 8084;
              };

              upstreams.groups.default = dnsServers;

              log = {
                level = "info";
                format = "json";
                privacy = true;
              };

              blocking = {
                loading.strategy = "fast";
                blockType = "zeroIP";
                denylists = {
                  ads = [
                    "https://adaway.org/hosts.txt"
                    "https://v.firebog.net/hosts/AdguardDNS.txt"
                    "https://v.firebog.net/hosts/Admiral.txt"
                    "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
                    "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
                    "https://v.firebog.net/hosts/Easylist.txt"
                    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
                    "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
                  ];
                  telemetry = [
                    "https://v.firebog.net/hosts/Easyprivacy.txt"
                    "https://v.firebog.net/hosts/Prigent-Ads.txt"
                    "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
                    "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
                    "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
                  ];
                };
                allowlists = {
                  ads = [ ];
                };
                clientGroupsBlock = {
                  default = [
                    "ads"
                    "telemetry"
                  ];
                };
              };

              caching = {
                minTime = "5m";
                maxTime = "30m";
                prefetching = true;
              };
            };
          };

          services.resolved.enable = lib.mkForce false;
        }
      ];
    };
}
