# The `desktop-packages` aspect (home-manager). Converted from the package list
# in home/programs/default.nix. The first group is platform-agnostic; the second
# group is the Linux-only desktop extras (previously gated behind
# `lib.optionals (!pkgs.stdenv.isDarwin)`).
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
