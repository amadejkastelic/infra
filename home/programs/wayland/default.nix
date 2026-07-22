{
  pkgs,
  self,
  lib,
  ...
}:
# Wayland config
{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprlux.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    # screenshot
    grim
    slurp

    # utils
    self.packages.${pkgs.stdenv.hostPlatform.system}.wl-ocr
    wl-clipboard
    wlr-randr
  ];

  systemd.user.targets.tray.Unit.Requires = lib.mkForce [ "graphical-session.target" ];
}
