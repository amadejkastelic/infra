{ ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "zfs" ];
    openFirewall = true;
  };
}
