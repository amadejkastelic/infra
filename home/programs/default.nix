{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./browsers
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
      signal-desktop
    ]
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
      kdePackages.ark
      pinentry-gnome3
      wineWow64Packages.wayland
      ledger-live-desktop
      qbittorrent-enhanced
      inputs.proxsign.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
