{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config)
    networking
    homelab
    ;

  port = 9090;
  textfileDir = "/var/lib/prometheus-node-exporter-textfiles";

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

  raplScript = pkgs.writeShellScript "rapl-collector" ''
    echo "# HELP node_rapl_energy_joules RAPL energy counter in joules"
    echo "# TYPE node_rapl_energy_joules counter"
    for dir in /sys/class/powercap/intel-rapl:*/; do
      [ -f "''${dir}energy_uj" ] || continue
      name=$(cat "''${dir}name" 2>/dev/null)
      energy=$(cat "''${dir}energy_uj" 2>/dev/null)
      [ -n "$energy" ] || continue
      joules=$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.3f\", $energy / 1000000}")
      echo "node_rapl_energy_joules{package=\"$name\"} $joules"
    done
  '';
in
{
  services.prometheus = {
    enable = true;
    enableReload = true;

    port = port;

    scrapeConfigs = map mkScrapeConfig exporterNames;

    exporters.node = {
      enable = true;
      enabledCollectors = [
        "textfile"
        "systemd"
      ];
      extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
    };

    exporters.postgres = {
      enable = true;
      user = "postgres_monitor";
      group = "postgres_monitor";
      dataSourceName = "user=postgres_monitor host=/run/postgresql dbname=postgres sslmode=disable";
    };

    exporters.nvidia-gpu.enable = true;
  };

  systemd.tmpfiles.settings."node-exporter-textfiles" = {
    "${textfileDir}".d = {
      mode = "0755";
    };
  };

  systemd.services.rapl-collector = {
    description = "Collect RAPL energy metrics for node_exporter textfile collector";
    script = ''
      ${raplScript} > ${textfileDir}/rapl.prom
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.rapl-collector = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "15s";
    };
  };

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
