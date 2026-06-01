{ inputs, lib, ... }:
let
  cache = builtins.fromJSON (builtins.readFile ./cache.json);
in
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

  den.aspects.base = {
    os =
      { pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          inputs.self.overlays.default
          (final: prev: {
            lib = prev.lib // {
              colors = import ../../lib/colors prev.lib;
            };
          })
          inputs.nix-vscode-extensions.overlays.default
          inputs.firefox-addons.overlays.default
        ];

        environment.systemPackages = [ pkgs.git ];

        time.timeZone = lib.mkDefault "Europe/Ljubljana";
      };

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.nix-exec.nixosModules.default ];

        nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];

        documentation.dev.enable = true;

        i18n = {
          defaultLocale = "en_US.UTF-8";
          supportedLocales = [ "en_US.UTF-8/UTF-8" ];
        };

        system.stateVersion = lib.mkDefault "23.11";

        zramSwap.enable = false;

        # den's HM battery imports the actual home-manager NixOS module; we only
        # set its options here.
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
        };

        nix =
          let
            flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
          in
          {
            package = pkgs.lixPackageSets.latest.lix;

            registry = lib.mapAttrs (_: v: { flake = v; }) flakeInputs;
            nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

            settings = {
              inherit (cache) substituters trusted-public-keys;
              auto-optimise-store = true;
              builders-use-substitutes = true;
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              flake-registry = "/etc/nix/registry.json";
              keep-derivations = true;
              keep-outputs = true;
              accept-flake-config = false;
              trusted-users = [
                "root"
                "@wheel"
              ];
            };

            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
          };

        programs.nix-exec = {
          enable = true;
          settings.sandbox.timeout = "5m";
        };

        # security tweaks borrowed from @hlissner
        boot.kernel.sysctl = {
          "kernel.sysrq" = 0;
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.all.accept_source_route" = 0;
          "net.ipv6.conf.all.accept_source_route" = 0;
          "net.ipv4.conf.all.send_redirects" = 0;
          "net.ipv4.conf.default.send_redirects" = 0;
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.default.accept_redirects" = 0;
          "net.ipv4.conf.all.secure_redirects" = 0;
          "net.ipv4.conf.default.secure_redirects" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.default.accept_redirects" = 0;
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv4.tcp_rfc1337" = 1;
          "net.ipv4.tcp_fastopen" = 3;
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "cake";
        };
        boot.kernelModules = [ "tcp_bbr" ];

        security = {
          pam.services.hyprlock.text = "auth include login";
          rtkit.enable = true;
          sudo.wheelNeedsPassword = false;
        };
      };

    darwin =
      { pkgs, ... }:
      {
        imports = [ inputs.determinate.darwinModules.default ];

        determinateNix = {
          enable = true;
          customSettings = {
            extra-substituters = cache.substituters;
            extra-trusted-public-keys = cache.trusted-public-keys;
          };
        };

        system.stateVersion = 6;

        programs.zsh.enable = true;
        environment.shells = [ pkgs.zsh ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
        };
      };

    homeManager =
      { pkgs, lib, ... }:
      {
        imports = [ inputs.nix-index-db.homeModules.nix-index ];

        home = {
          stateVersion = "23.11";
          extraOutputsToInstall = [
            "doc"
            "devdoc"
          ];
        };

        manual = {
          html.enable = false;
          json.enable = false;
          manpages.enable = false;
        };

        targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
          linkApps.enable = false;
          copyApps.enable = true;
        };

        # darwin: Determinate owns Nix so the system nix.package is unset; HM needs one
        nix.package = lib.mkIf pkgs.stdenv.isDarwin pkgs.nix;

        programs.home-manager.enable = true;
      };
  };
}
