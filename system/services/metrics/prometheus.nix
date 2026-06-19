let
  port = 9090;
  oblakIp = "192.168.1.6";
in
{
  services.prometheus = {
    enable = true;
    enableReload = true;

    port = port;

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
            labels.hostname = "razer";
          }
          {
            targets = [ "${oblakIp}:9100" ];
            labels.hostname = "oblak";
          }
        ];
      }
    ];

    exporters.node.enable = true;
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
}
