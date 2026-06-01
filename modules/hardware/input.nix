{
  den.aspects.input.nixos =
    { pkgs, ... }:
    {
      # Disable controller touchpad
      services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="event[0-9]*", ATTRS{name}=="*Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"

        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0b10", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';

      # Logitech G923
      hardware.new-lg4ff.enable = false;

      services.udev.packages = [
        pkgs.oversteer
        pkgs.via
      ];

      environment.systemPackages = [
        pkgs.oversteer
        pkgs.via
      ];
    };
}
