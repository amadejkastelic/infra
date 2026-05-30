{ pkgs, lib, ... }:
{
  imports = [
    ./bat.nix
    ./btop.nix
    ./cli.nix
    ./git.nix
    ./nix.nix
    ./skim.nix
    ./xdg.nix
  ]
  ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    ./transient-services.nix
  ];
}
