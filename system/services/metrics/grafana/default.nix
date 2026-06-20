{ config, ... }:
{
  homelab.subdomains = [ "grafana" ];
  imports = [
    ./datasources.nix
    ./dashboards
    ./alerting.nix
    ./rules.nix
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
        root_url = "https://grafana.${config.homelab.domain}/";
        serve_from_sub_path = false;
      };
      users = {
        allow_sign_up = false;
        default_theme = "dark";
      };
    };
  };
}
