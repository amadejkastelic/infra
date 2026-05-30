{
  imports = [
    # editors
    ../../editors/neovim
    ../../editors/vscode
    ../../editors/zed

    # programs
    ../../programs
    ../../programs/games
    ../../programs/office
    ../../programs/vicinae
    ../../programs/wayland

    # services
    ../../services/networkmanager
    ../../services/gpg

    # media services
    ../../services/media/playerctl.nix
    ../../services/media/easyeffects.nix

    # system services
    ../../services/system/polkit-agent.nix
    ../../services/system/cliphist.nix

    # wayland-specific
    ../../services/wayland/hyprpaper.nix
    ../../services/wayland/hypridle.nix
    ../../services/wayland/hyprsunset.nix

    # terminal emulators
    ../../terminal/emulators/kitty.nix
    ../../terminal/emulators/ghostty.nix
  ];
}
