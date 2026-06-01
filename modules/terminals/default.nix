# The `terminals` aspect (home-manager). kitty + ghostty terminal emulators.
# Converted from home/terminal/emulators/{kitty,ghostty}.nix.
{
  den.aspects.terminals.homeManager =
    { pkgs, ... }:
    {
      programs.kitty = {
        enable = true;

        settings = {
          scrollback_lines = 10000;
          placement_strategy = "center";

          allow_remote_control = "yes";
          enable_audio_bell = "no";

          copy_on_select = "clipboard";

          selection_foreground = "none";
          selection_background = "none";
        };
      };

      programs.ghostty = {
        enable = true;

        package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

        enableZshIntegration = true;

        clearDefaultKeybinds = false;

        settings = {
          window-decoration = pkgs.stdenv.isDarwin;
          gtk-titlebar = false;
          cursor-style = "bar";
        };
      };
    };
}
