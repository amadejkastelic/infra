# ryzen — x86_64 desktop (hyprland, gaming, virtualisation).
{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.ryzen.users.amadejk = { };

  den.aspects.ryzen = {
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
      openrgb
      location
      gnome-services
      server-services
      # gaming + virtualisation
      gaming
      virtualisation
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          ./_hyprland.nix
          ./_openrgb
          ./_thermal-fix.nix
        ];

        networking.hostName = "ryzen";
        nixpkgs.hostPlatform = "x86_64-linux";

        services.scx = {
          enable = true;
          package = pkgs.scx.full;
          scheduler = "scx_lavd";
        };

        environment.systemPackages = with pkgs; [ pcscliteWithPolkit ];

        hardware.opentabletdriver.enable = true;

        security.tpm2.enable = true;

        # Windows dual-boot time fix
        time.hardwareClockInLocalTime = true;

        services.fstrim.enable = true;
      };
  };
}
