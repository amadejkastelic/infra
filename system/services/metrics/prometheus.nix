{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 9090;
  oblakIp = "192.168.1.6";
  textfileDir = "/var/lib/prometheus-node-exporter-textfiles";

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
        relabel_configs = [
          {
            source_labels = [ "hostname" ];
            target_label = "instance";
          }
        ];
      }
    ];

    exporters.node = {
      enable = true;
      enabledCollectors = [ "textfile" ];
      extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
    };
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
