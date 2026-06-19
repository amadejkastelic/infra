{ lib, ... }:
let
  domain = "amadejk.com";

  subdomains = [
    "home"
    "jellyfin"
    "sonarr"
    "sonarr-anime"
    "sonarr-kdrama"
    "radarr"
    "bazarr"
    "prowlarr"
    "qbittorrent"
    "jellyseerr"
    "vaultwarden"
    "blocky"
    "immich"
  ];

  subdomainHosts = map (s: "${s}.${domain}") subdomains;
in
{
  services.nginx = {
    enable = true;
    enableReload = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = lib.genAttrs subdomainHosts (_: {
      forceSSL = true;
      useACMEHost = domain;
      extraConfig = ''
        allow 127.0.0.1;
        allow 192.168.1.0/24;
        allow 100.64.0.0/10;
        deny all;
      '';
    });
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };
}
