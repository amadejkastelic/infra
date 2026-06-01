{
  description = "amadejk's NixOS and Home-Manager flake";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [
        ./home/profiles
        ./hosts
        ./lib
        ./modules
        ./pkgs
        ./pre-commit-hooks.nix
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              just
              nixd
              nixfmt
              nodejs-slim
              git
              config.packages.repl
            ];
            name = "dots";
            DIRENV_LOG_FORMAT = "";
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          formatter = pkgs.nixfmt;
        };
    };

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # https://github.com/microsoft/vscode/issues/260391
    nixpkgs-vscode.url = "github:NixOS/nixpkgs?ref=4c7d90a136071eb8154d6b3fe63b0046de9d4712";

    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.55.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprsunset = {
      url = "github:hyprwm/hyprsunset";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprlux = {
      url = "github:amadejkastelic/Hyprlux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprvibr = {
      url = "github:amadejkastelic/hyprvibr?ref=chase-hypr";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-userstyles.url = "github:knoopx/nix-userstyles";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipboard-sync.url = "github:dnut/clipboard-sync";

    sekiro-tweaker.url = "github:amadejkastelic/sekiro-tweaker";

    vicinae.url = "github:vicinaehq/vicinae";
    vicinae-extensions.url = "github:vicinaehq/extensions";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "hm";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nanofetch.url = "github:amadejkastelic/nanofetch";

    grabby.url = "github:amadejkastelic/grabby";

    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix.url = "github:musnix/musnix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxsign.url = "github:amadejkastelic/proxsign-nix";

    claude-code.url = "github:sadjow/claude-code-nix";

    bb-launcher.url = "github:amadejkastelic/bb-launcher-nix";

    nix-exec.url = "github:amadejkastelic/nix-exec";
  };
}
