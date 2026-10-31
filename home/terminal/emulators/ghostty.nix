{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;

    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    enableZshIntegration = true;

    clearDefaultKeybinds = false;

    settings = {
      window-decoration = pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;
      cursor-style = "bar";
      background-blur = true;
      background-opacity = 0.8;
    };
  };
}
