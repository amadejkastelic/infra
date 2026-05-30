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
  imports = [
    inputs.stylix.nixosModules.stylix
    ./shared.nix
  ];

  stylix = {
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

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
    };
  };
}
