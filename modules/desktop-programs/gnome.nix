# `gnome` aspect (Linux/NixOS): GDM display manager + GNOME desktop, trimmed down.
# Replaces system/programs/gnome/default.nix.
{
  den.aspects.gnome.nixos =
    { pkgs, ... }:
    {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        gnome = {
          core-apps.enable = false;
          core-developer-tools.enable = false;
          games.enable = false;
        };
      };

      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
      ];
    };
}
