{ pkgs, ... }:
{
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
}
