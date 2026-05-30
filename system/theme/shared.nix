{
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    autoEnable = true;

    image = ./wallpaper.jpeg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    fonts.sizes = {
      applications = 11;
      desktop = 11;
      popups = 9;
      terminal = 12;
    };

    opacity = {
      applications = 0.93;
      terminal = 0.93;
    };
  };
}
