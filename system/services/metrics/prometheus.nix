{
  config,
  lib,
  ...
}:
let
  inherit (config)
    networking
    homelab
    ;

  port = 9090;

  exporterPorts = {
    node = config.services.prometheus.exporters.node.port;
    postgres = config.services.prometheus.exporters.postgres.port;
    nvidia-gpu = config.services.prometheus.exporters.nvidia-gpu.port;
  };

  exporterNames = lib.unique (lib.concatLists (lib.mapAttrsToList (_: h: h.exporters) homelab.hosts));

  mkScrapeConfig =
    name:
    let
      eport = exporterPorts.${name};
      targetHosts = lib.attrNames (lib.filterAttrs (_: h: lib.elem name h.exporters) homelab.hosts);
      staticConfig =
        hname:
        let
          addr = if hname == networking.hostName then "localhost" else homelab.hosts.${hname}.ip;
        in
        {
          targets = [ "${addr}:${toString eport}" ];
          labels.hostname = hname;
        };
    in
    {
      job_name = name;
      static_configs = map staticConfig targetHosts;
      relabel_configs = [
        {
          source_labels = [ "hostname" ];
          target_label = "instance";
        }
      ];
    };
in
{
  services.prometheus = {
    enable = true;
    enableReload = true;

    port = port;

    scrapeConfigs = map mkScrapeConfig exporterNames;

    exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };

    exporters.postgres = {
      enable = true;
      user = "postgres_monitor";
      group = "postgres_monitor";
      dataSourceName = "user=postgres_monitor host=/run/postgresql dbname=postgres sslmode=disable";
    };

    exporters.nvidia-gpu.enable = true;
  };

  services.rapl-collector.enable = true;

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      uid = "prometheus";
      url = "http://localhost:${toString port}";
      isDefault = true;
    }
  ];

  hardware.i2c.enable = true;
}
