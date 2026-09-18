{
  lib,
  config,
  pkgs,
  ...
}:
let
  dnsServers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
in
{
  homelab.subdomains = [ "blocky" ];
  networking.nameservers = [ "127.0.0.1" ] ++ dnsServers;

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.blocky = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "blocky.${config.homelab.domain}";
    };

    settings = {
      ports = {
        dns = 53;
        http = 8084;
      };

      upstreams.groups.default = dnsServers;
      bootstrapDns = dnsServers;

      log = {
        level = "info";
        format = "json";
        privacy = true;
      };

      blocking = {
        loading = {
          strategy = "fast";
          refreshPeriod = "24h";
          downloads = {
            timeout = "30s";
            readTimeout = "30s";
            attempts = 5;
            cooldown = "5s";
          };
        };
        blockType = "zeroIP";
        denylists.standard = [
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.medium.txt"
        ];
        allowlists.standard = [
          (pkgs.writeText "blocky-allowlist-standard" ''
            triglav.si
            *.triglav.si
          '')
        ];
        clientGroupsBlock = {
          default = [ "standard" ];
        };
      };

      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };

      prometheus.enable = true;

      customDNS.mapping = builtins.listToAttrs (
        map (sub: {
          name = "${sub}.${config.homelab.domain}";
          value = config.homelab.dnsServerIp;
        }) config.homelab.subdomains
      );
    };
  };

  services.resolved.enable = lib.mkForce false;
}
