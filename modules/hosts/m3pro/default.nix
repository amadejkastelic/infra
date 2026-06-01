# m3pro — aarch64 macOS laptop (nix-darwin). den derives class="darwin" from the
# aarch64-darwin system, producing flake.darwinConfigurations.m3pro automatically.
#
# NOTE: only cross-platform + darwin aspects are included here. Linux-only home
# aspects (gtk, qt, wayland, hyprland, games, media/noisetorch) are intentionally
# excluded. Adjust this list to taste.
{ den, ... }:
{
  den.hosts.aarch64-darwin.m3pro.users.amadejk = { };

  den.aspects.m3pro = {
    provides.to-users.includes = with den.aspects; [
      # core (base/secrets/user carry os/darwin/homeManager)
      base
      secrets
      amadejk
      theme
      # macOS system
      homebrew
      macos-preferences
      macos-security
      # cross-platform home-manager
      shell
      nushell
      starship
      atuin
      carapace
      zsh
      bat
      btop
      cli
      git
      nix-tools
      skim
      transient-services
      xdg
      claude
      mcp
      opencode
      terminals
      neovim
      vscode
      zed
      # mac-safe extras
      browsers
      social
      gpg
      nix-access-tokens
      desktop-packages
    ];

    darwin = {
      networking.hostName = "m3pro";
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  };
}
