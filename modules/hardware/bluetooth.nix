{
  den.aspects.bluetooth.nixos =
    { pkgs, ... }:
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        package = pkgs.bluez-experimental;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };

      services.blueman.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/114222
      systemd.user.services.telephony_client.enable = false;
    };
}
