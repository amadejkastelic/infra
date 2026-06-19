{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  networking.nameservers = [
    "192.168.1.8"
    "1.1.1.1"
  ];

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "enp1s0";
      address = [ "192.168.1.6/24" ];
      gateway = [ "192.168.1.1" ];
    };
  };
}
