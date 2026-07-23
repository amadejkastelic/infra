{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.writers) writeDash;

  hyprctl = "${lib.getExe' config.programs.hyprland.package "hyprctl"} -i 0";
  powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
  notify-send = lib.getExe pkgs.libnotify;

  resolutionScript = pkgs.writeShellScriptBin "resolution" ''
    refresh_rate=''${3:-120}
    ${hyprctl} eval "hl.monitor({ output = \"DP-2\", mode = \"$1x$2@''${refresh_rate}\", position = \"0x0\", scale = 1 })"
  '';

  startScript = writeDash "gamemode-start" ''
    ${lib.getExe resolutionScript} 2560 1440
    ${hyprctl} hyprsunset identity
    ${hyprctl} eval "hl.config({
      animations = { enabled = false },
      decoration = {
        shadow = { enabled = false },
        blur = { enabled = false },
        rounding = 0,
      },
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,
      },
    })"
    ${powerprofilesctl} set performance
    ${notify-send} -u low -a 'Gamemode' 'Optimizations activated'
  '';
  endScript = writeDash "gamemode-end" ''
    ${hyprctl} hyprsunset reset
    ${hyprctl} reload
    ${powerprofilesctl} set balanced
    ${notify-send} -u low -a 'Gamemode' 'Optimizations deactivated'
  '';
in
{
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
}
