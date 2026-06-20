{ config, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "zfs"
      "systemd"
    ];
    openFirewall = true;
  };

  services.journald-loki = {
    enable = true;
    lokiUrl = "http://${config.homelab.hosts.razer.ip}:3100/loki/api/v1/push";
  };
}
