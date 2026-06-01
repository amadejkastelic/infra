{ inputs, ... }:
{
  den.aspects.desktop-packages.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages =
        (with pkgs; [
          gnumake
          hoppscotch
        ])
        ++ lib.optionals (!pkgs.stdenv.isDarwin) (
          (with pkgs; [
            pinentry-gnome3
            mission-center
            wineWow64Packages.wayland
            ledger-live-desktop
            qbittorrent-enhanced
            gnome-disk-utility
          ])
          ++ [ inputs.proxsign.packages.${pkgs.stdenv.hostPlatform.system}.default ]
        );
    };
}
