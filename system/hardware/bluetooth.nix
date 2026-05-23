{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez-experimental;
    settings = {
      General = {
        # Battery info for Bluetooth devices
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/114222
  systemd.user.services.telephony_client.enable = false;
}
