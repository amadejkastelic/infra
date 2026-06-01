{ inputs, ... }:
{
  den.aspects.desktop-packages.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages =
        (with pkgs; [
          gnumake
          hoppscotch
        ])
        ++ (with pkgs; [
          pinentry-gnome3
          mission-center
          wineWow64Packages.wayland
          ledger-live-desktop
          qbittorrent-enhanced
          gnome-disk-utility
        ])
        ++ [
          inputs.proxsign.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
    };
}
