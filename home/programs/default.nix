{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./browsers/zen.nix
    ./media
    ./nix.nix
    ./gtk.nix
    ./qt.nix
    ./social
  ];

  home.packages =
    with pkgs;
    [
      gnumake
      hoppscotch
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      pinentry-gnome3
      mission-center
      wineWow64Packages.wayland
      ledger-live-desktop
      qbittorrent-enhanced
      gnome-disk-utility
      inputs.proxsign.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
