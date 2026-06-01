# `gnome-services` aspect (Linux/NixOS): GNOME services (keyring, gvfs, tumbler)
# usable outside the GNOME desktop.
# Replaces system/services/gnome-services.nix.
{
  den.aspects.gnome-services.nixos =
    { pkgs, ... }:
    {
      services = {
        # needed for GNOME services outside of GNOME Desktop
        dbus.packages = with pkgs; [
          gcr
          gnome-settings-daemon
        ];

        gnome.gnome-keyring.enable = true;

        gvfs.enable = true;
        tumbler.enable = true;
      };
    };
}
