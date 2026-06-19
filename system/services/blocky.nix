{ lib, ... }:
let
  dnsServers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
in
{
  networking.nameservers = [ "127.0.0.1" ] ++ dnsServers;

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.blocky = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "blocky.amadejk.com";
    };

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

      customDNS.mapping = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = "192.168.1.8";
          })
          [
            "home.amadejk.com"
            "jellyfin.amadejk.com"
            "sonarr.amadejk.com"
            "sonarr-anime.amadejk.com"
            "sonarr-kdrama.amadejk.com"
            "radarr.amadejk.com"
            "bazarr.amadejk.com"
            "prowlarr.amadejk.com"
            "qbittorrent.amadejk.com"
            "jellyseerr.amadejk.com"
            "vaultwarden.amadejk.com"
            "blocky.amadejk.com"
            "immich.amadejk.com"
          ]
      );
    };
  };

  services.resolved.enable = lib.mkForce false;
}
