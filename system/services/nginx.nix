{
  config,
  lib,
  ...
}:
let
  domain = config.homelab.domain;
  subdomainHosts = map (s: "${s}.${domain}") config.homelab.subdomains;
in
{
  services.nginx = {
    enable = true;
    enableReload = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts =
      (lib.genAttrs subdomainHosts (_: {
        forceSSL = true;
        useACMEHost = domain;
        extraConfig = ''
          allow 127.0.0.1;
          allow ${config.homelab.lanCidr};
          allow ${config.homelab.tailnetCidr};
          deny all;
        '';
      }))
      // {
        ${domain} = {
          forceSSL = true;
          useACMEHost = domain;
          locations."/".proxyPass = "https://amadejkastelic.github.io";
          extraConfig = ''
            proxy_ssl_server_name on;
          '';
        };
      };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
