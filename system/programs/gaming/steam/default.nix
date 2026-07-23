{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
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

  programs.steam = {
    enable = true;

    config = {
      enable = true;
      onSteamRunning = "close";
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
              files.install."game/csgo/cfg/autoexec.cfg".source = ./cs2/autoexec.cfg;
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
}
