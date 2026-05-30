{ pkgs, ... }:
{
  imports = [
    ../../editors/neovim
    ../../editors/vscode
    ../../editors/zed

    ../../programs
    ../../programs/browsers/zen.nix
    ../../programs/browsers/chromium.nix

    ../../services/gpg

    ../../terminal/emulators/kitty.nix
    ../../terminal/emulators/ghostty.nix
  ];

  services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
}
