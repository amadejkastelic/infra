# `xdg` aspect (Linux/NixOS): XDG desktop portal config (gtk + hyprland).
# Replaces system/programs/xdg.nix.
{
  den.aspects.xdg.nixos =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config = {
          common.default = [ "gtk" ];
          hyprland.default = [
            "gtk"
            "hyprland"
          ];
        };

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };
}
