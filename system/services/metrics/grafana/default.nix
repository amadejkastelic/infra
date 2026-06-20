{ config, ... }:
{
  homelab.subdomains = [ "grafana" ];
  imports = [
    ./datasources.nix
    ./dashboards
  ];

  services.grafana = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "grafana.${config.homelab.domain}";
    };
    provision.enable = true;

    settings = {
      security.secret_key = "p7Lrdv/uzMcLrvFN+ImmjAycrXYBTpZqMIzlBOJHBVU=";
      server = {
        http_port = 3000;
        http_addr = "0.0.0.0";
        enable_gzip = true;
      };
      users = {
        allow_sign_up = false;
        default_theme = "dark";
      };
    };
  };
}
