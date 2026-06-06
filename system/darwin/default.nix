{
  self,
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.hm.darwinModules.default
    inputs.stylix.darwinModules.stylix
    inputs.determinate.darwinModules.default
    ../theme/shared.nix
    ./preferences.nix
    ./homebrew.nix
  ];

  stylix.fonts = {
    serif = {
      package = pkgs.emptyDirectory;
      name = "SFProText";
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

  system.primaryUser = "amadejk";

  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
  };

  system.stateVersion = 6;

  time.timeZone = "Europe/Ljubljana";

  users.users.amadejk = {
    home = "/Users/amadejk";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
  };

  determinateNix = {
    enable = true;

    registry =
      let
        flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
      in
      lib.mapAttrs (_: v: { flake = v; }) flakeInputs;

    customSettings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      flake-registry = "/etc/nix/registry.json";
      keep-derivations = true;
      keep-outputs = true;
      accept-flake-config = false;
      trusted-users = [
        "root"
        "@admin"
      ];
    };

    determinateNixd.garbageCollector.strategy = "disabled";
  };

  environment.systemPackages = with pkgs; [
    raycast
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        lib = prev.lib // {
          colors = import "${self}/lib/colors" prev.lib;
        };
      })
      inputs.nix-vscode-extensions.overlays.default
      inputs.firefox-addons.overlays.default
    ];
  };
}
