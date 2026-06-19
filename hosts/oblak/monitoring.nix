{ ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "zfs"
      "systemd"
    ];
    openFirewall = true;
  };
}
