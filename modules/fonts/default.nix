# `fonts` aspect (Linux/NixOS): system font packages and fontconfig defaults.
# Replaces system/programs/fonts.nix.
{
  den.aspects.fonts.nixos =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          # icon fonts
          material-symbols

          # Sans(Serif) fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          roboto
          (google-fonts.override { fonts = [ "Inter" ]; })

          # monospace fonts
          jetbrains-mono

          # nerdfonts
          nerd-fonts.symbols-only
          nerd-fonts.jetbrains-mono
        ];

        # causes more issues than it solves
        enableDefaultPackages = false;

        # user defined fonts
        # the reason there's Noto Color Emoji everywhere is to override DejaVu's
        # B&W emojis that would sometimes show instead of some Color emojis
        fontconfig.defaultFonts = {
          serif = [
            "Noto Serif"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Inter"
            "Noto Color Emoji"
          ];
          monospace = [
            "JetBrains Mono"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
