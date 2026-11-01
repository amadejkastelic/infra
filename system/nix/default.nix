{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./nixpkgs.nix
    ./substituters.nix
  ];

  # we need git for flakes
  environment.systemPackages = [ pkgs.git ];

  nix = {
    package = pkgs.lixPackageSets.latest.lix;

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry.nixpkgs.flake = inputs.nixpkgs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      accept-flake-config = false;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
