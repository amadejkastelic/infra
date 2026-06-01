{
  den.aspects.metrics.nixos =
    let
      port = 9090;
    in
    {
      services.grafana = {
        enable = true;
        nginx.enable = true;
        provision.enable = true;

        settings = {
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

      services.grafana.provision.datasources.settings = {
        apiVersion = 1;
        prune = true;
      };

      services.prometheus = {
        enable = true;
        enableReload = true;

        port = port;

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [ { targets = [ "localhost:9100" ]; } ];
          }
          {
            job_name = "sensors";
            static_configs = [ { targets = [ "localhost:9216" ]; } ];
          }
        ];

        exporters = {
          node.enable = true;
          systemd.enable = true;
        };
      };

      services.grafana.provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString port}";
          isDefault = true;
        }
      ];

      hardware.i2c.enable = true;
    };
}
