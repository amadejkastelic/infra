# The `games` aspect (home-manager, Linux desktop).
# Converted from home/programs/games/{default,bloodborne,mangohud,osu}.nix.
{ inputs, ... }:
{
  den.aspects.games.homeManager =
    {
      pkgs,
      ...
    }:
    let
      osu = pkgs.osu-lazer-bin.override { nativeWayland = true; };

      osu-wrapped = pkgs.symlinkJoin {
        name = "osu-lazer-wrapped";
        paths = [ osu ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          mv $out/bin/osu! $out/bin/.osu!-unwrapped

          makeWrapper ${pkgs.gamemode}/bin/gamemoderun $out/bin/osu! \
            --add-flags "$out/bin/.osu!-unwrapped"
        '';
      };
    in
    {
      imports = [ inputs.bb-launcher.homeManagerModules.default ];

      home.packages =
        (with pkgs; [
          winetricks
          adwsteamgtk
          steam-run
          oversteer
          shadps4
          # cemu
          eden
          ryubing
          dolphin-emu
        ])
        ++ [ osu-wrapped ];

      programs.bb-launcher = {
        enable = true;
        gameInstallPath = "/mnt/ssd1/PS4/CUSA03173/";
        wrapperCommand = "gamemoderun mangohud";
      };

      programs.mangohud = {
        enable = true;
        settings = {
          full = false;
          cpu_temp = true;
          gpu_temp = true;
          vram = false;
          frame_timing = false;
          toggle_hud = "Shift_L+F11";
          position = "top-right";
        };
      };
    };
}
