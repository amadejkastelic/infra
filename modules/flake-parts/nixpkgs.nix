# pkgs-by-name-for-flake-parts: every pkgs/by-name/<name>/package.nix becomes a
# flake-parts perSystem package (flake.packages.<system>.<name>), and
# flake.overlays.default re-exposes them as pkgs.local.* so they can be used
# inside den aspect nixos/darwin/homeManager blocks (see modules/base).
{ inputs, withSystem, ... }:
{
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  };

  imports = [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      pkgsDirectory = ../../pkgs/by-name;
    };

  flake.overlays.default = _final: prev: {
    local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
  };
}
