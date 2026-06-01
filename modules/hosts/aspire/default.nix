# aspire — x86_64 laptop (hyprland + power management).
{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.aspire.users.amadejk = { };

  den.aspects.aspire = {
    provides.to-users.includes = with den.aspects; [
      # core
      base
      secrets
      network
      amadejk
      nfs-mount
      # shared home-manager
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
      theme
      neovim
      vscode
      zed
      # linux desktop home-manager
      gtk
      qt
      browsers
      media
      office
      vicinae
      wayland
      social
      nix-access-tokens
      desktop-packages
      networkmanager
      gpg
      playerctl
      easyeffects
      desktop-services
      games
      # linux desktop system
      boot
      lanzaboote
      hyprland
      fonts
      dconf
      nautilus
      thunar
      obs
      noisetorch
      idescriptor
      gnome
      bluetooth
      input
      ledger
      opengl
      luks
      greetd
      pipewire
      gpg-system
      printing
      clipboard-sync
      location
      gnome-services
      server-services
      # laptop
      power
      cpu-aspire
    ];

    nixos =
      { lib, pkgs, ... }:
      {
        imports = [
          inputs.disko.nixosModules.disko
          ./_hardware-configuration.nix
          ./_disk-config.nix
          ./_hyprland.nix
        ];

        networking.hostName = "aspire";
        nixpkgs.hostPlatform = "x86_64-linux";

        services.openssh.enable = true;

        environment.systemPackages = map lib.lowPrio [
          pkgs.curl
          pkgs.gitMinimal
        ];

        services.fstrim.enable = true;
        powerManagement.enable = true;
      };
  };
}
