{ config, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "zfs"
      "systemd"
      "textfile"
    ];
    extraFlags = [
      "--collector.textfile.directory=/var/lib/prometheus-node-exporter-textfiles"
    ];
    openFirewall = true;
  };

  services.rapl-collector.enable = true;
  services.nixos-info-collector.enable = true;

  services.journald-loki = {
    enable = true;
    lokiUrl = "http://${config.homelab.hosts.razer.ip}:3100/loki/api/v1/push";
  };
}
