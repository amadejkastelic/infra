{
  homelab.subdomains = [ "grafana" ];
  imports = [ ./datasources.nix ];

  services.grafana = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "grafana.amadejk.com";
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
