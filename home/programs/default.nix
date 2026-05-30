{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./browsers/chromium.nix
    ./browsers/zen.nix
    ./media
    ./nix.nix
    ./gtk.nix
    ./qt.nix
    ./office
    ./social
  ]
  ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    ./vicinae
  ];

  home.packages =
    with pkgs;
    [
      gnumake
      hoppscotch
      pinentry-gnome3
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      mission-center
      wineWow64Packages.wayland
      ledger-live-desktop
      qbittorrent-enhanced
      gnome-disk-utility
      inputs.proxsign.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
