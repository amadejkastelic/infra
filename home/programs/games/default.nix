{ pkgs, self, ... }:
{
  imports = [
    ./bloodborne.nix
    ./mangohud.nix
    ./osu.nix
  ];

  home.packages =
    with pkgs;
    [
      winetricks
      adwsteamgtk
      steam-run
      oversteer
      shadps4
      # cemu
      eden
      ryubing
      dolphin-emu
    ]
    ++ [ self.packages.${pkgs.stdenv.hostPlatform.system}.lichii ];
}
