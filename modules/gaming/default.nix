# `gaming` aspect (Linux/NixOS): Steam, gamescope, gamemode, switch tooling and
# power-profiles-daemon. Combined into a single nixos block to avoid functor
# merges across files.
# Replaces system/programs/gaming/{default,steam,switch,gamemode,gamescope}.nix.
{ inputs, ... }:
{
  den.aspects.gaming.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # --- gamemode helpers ---
      inherit (pkgs.writers) writeDash;

      hyprctl = "${lib.getExe' config.programs.hyprland.package "hyprctl"} -i 0";
      powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
      notify-send = lib.getExe pkgs.libnotify;

      resolutionScript = pkgs.writeShellScriptBin "resolution" ''
        refresh_rate=''${3:-120}
        ${hyprctl} keyword monitor "DP-2,$1x$2@''${refresh_rate},0x0,1"
      '';

      startScript = writeDash "gamemode-start" ''
        ${lib.getExe resolutionScript} 2560 1440
        ${hyprctl} hyprsunset identity
        ${hyprctl} --batch "\
          keyword animations:enabled 0;\
          keyword decoration:shadow:enabled 0;\
          keyword decoration:blur:enabled 0;\
          keyword general:gaps_in 0;\
          keyword general:gaps_out 0;\
          keyword general:border_size 1;\
          keyword plugin:dynamic-cursors:enabled 0;\
          keyword decoration:rounding 0"
        ${powerprofilesctl} set performance
        ${notify-send} -u low -a 'Gamemode' 'Optimizations activated'
      '';
      endScript = writeDash "gamemode-end" ''
        ${hyprctl} hyprsunset reset
        ${hyprctl} reload
        ${powerprofilesctl} set balanced
        ${notify-send} -u low -a 'Gamemode' 'Optimizations deactivated'
      '';

      # --- steam helpers ---
      defaults = {
        launchOptions = {
          env = { };
          wrappers = [
            (lib.getExe pkgs.gamemode)
            (lib.getExe pkgs.mangohud)
          ];
        };
      };
    in
    {
      imports = [
        inputs.nix-gaming.nixosModules.platformOptimizations
        inputs.steam-config-nix.nixosModules.default
      ];

      services.power-profiles-daemon.enable = true;

      # switch.nix
      programs.quark-goldleaf.enable = false;

      # gamescope.nix
      programs.gamescope = {
        enable = true;
        package = pkgs.gamescope;
        args = [
          "--backend wayland"
          "--force-grab-cursor"
          "-W 2560"
          "-H 1440"
          "-r 120"
          "-f"
        ];
      };

      # gamemode.nix
      environment.systemPackages = [ resolutionScript ];

      programs.gamemode = {
        enable = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
          };

          custom = {
            start = startScript.outPath;
            end = endScript.outPath;
          };
        };
      };

      # steam.nix
      programs.steam = {
        enable = true;

        config = {
          enable = true;
          closeSteam = true;
          defaultCompatTool = "GE-Proton";

          apps =
            lib.mapAttrs
              (
                _: options:
                lib.mkMerge [
                  options
                  defaults
                ]
              )
              {
                cs2 = {
                  id = 730;
                  launchOptions = {
                    env.SDL_VIDEO_DRIVER = "wayland";
                    args = [
                      "-window"
                      "-nojoy"
                      "-w 1920"
                      "-h 1440"
                      "-trusted"
                      "-novid"
                      "-freq 120"
                      "+fps_max 0"
                      "+exec autoexec"
                    ];
                  };
                };
              };
        };

        package = pkgs.steam.override {
          buildFHSEnv =
            args:
            pkgs.buildFHSEnv (
              args
              // {
                #extraPreBwrapCmds =
                #  (args.extraPreBwrapCmds or "")
                #  + ''
                #    cp /etc/static/gamemode.ini /tmp/gamemode.ini
                #    chmod 666 /tmp/gamemode.ini
                #  '';
                extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [
                  "--bind /run/user/1000/hypr /tmp/hypr"
                  #"--ro-bind /tmp/gamemode.ini /etc/gamemode.ini"
                ];
              }
            );

          extraPkgs =
            pkgs: with pkgs; [
              gamemode
              config.programs.hyprland.package
              inputs.sekiro-tweaker.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];

          extraLibraries =
            pkgs: with pkgs; [
              gamemode
              pkgsi686Linux.gamemode
            ];
        };

        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];

        protontricks.enable = true;
        platformOptimizations.enable = true;
      };

      hardware = {
        graphics.enable32Bit = true;
        steam-hardware.enable = true;
      };
    };
}
