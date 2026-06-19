{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "enp0s20f0u2";
      address = [ "192.168.1.8/24" ];
      gateway = [ "192.168.1.1" ];
    };
  };
}
