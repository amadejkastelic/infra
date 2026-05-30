{ pkgs, lib, ... }:
{
  imports = [ ./mpv.nix ];

  home.packages =
    with pkgs;
    [
      gimp
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      pavucontrol
      pulsemixer
      loupe
      audacious
      cider-2
    ];
}
