{
  config,
  lib,
  ...
}:
{
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  networking.nameservers = [
    config.homelab.dnsServerIp
    "1.1.1.1"
  ];

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "enp1s0";
      address = [ "${config.homelab.hosts.oblak.ip}/24" ];
      gateway = [ "192.168.1.1" ];
    };
  };
}
