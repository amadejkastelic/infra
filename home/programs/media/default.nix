{ pkgs, lib, ... }:
{
  imports = [ ./mpv.nix ];

  home.packages =
    with pkgs;
    lib.optionals (!pkgs.stdenv.isDarwin) [
      gimp
      pavucontrol
      pulsemixer
      loupe
      audacious
      cider-2
    ];
}
