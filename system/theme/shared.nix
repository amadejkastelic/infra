{
  pkgs,
  inputs,
  config,
  ...
}:
let
  appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  stylix = {
    enable = true;
    autoEnable = true;

    image = ./wallpaper.jpeg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    fonts = {
      serif = {
        package = appleFonts.sf-pro-nerd;
        name = "SFProText Nerd Font";
      };

      sansSerif = config.stylix.fonts.serif;

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 11;
        desktop = 11;
        popups = 9;
        terminal = 12;
      };
    };

    opacity = {
      applications = 0.93;
      terminal = 0.93;
    };
  };
}
