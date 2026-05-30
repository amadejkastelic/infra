{ pkgs, lib, ... }:
{
  stylix = {
    enable = true;

    autoEnable = true;

    icons = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    targets = {
      opencode.enable = false;
      neovim.enable = false;
      nixcord.enable = false;
      mangohud.enable = false;
      hyprlock.enable = false;
      zen-browser.profileNames = [ "default" ];
      hyprpaper.enable = false;
      nushell.enable = false;
      starship.enable = false;
      zed.enable = false;
    };
  };
}
