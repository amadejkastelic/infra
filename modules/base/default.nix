{ inputs, lib, ... }:
let
  cache = builtins.fromJSON (builtins.readFile ./cache.json);
in
{
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

        # NixOS hosts manage Nix (Lix) themselves. The darwin host uses the
        # Determinate distribution, which self-manages the daemon (see below).
        nix =
          let
            flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
          in
          {
            package = pkgs.lixPackageSets.latest.lix;

            # pin the registry to avoid re-evaling nixpkgs every time
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
        system.stateVersion = 6;

        # Determinate Nix self-manages the daemon (determinate-nixd); nix-darwin
        # must not manage Nix or write nix.conf. Daemon settings, gc, trusted-users
        # and extra substituters are configured via Determinate (/etc/nix/nix.custom.conf).
        nix.enable = false;

        # register the Nix-store zsh as a valid login shell so chsh/login stays
        # stable across rebuilds
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

        programs.home-manager.enable = true;
      };
  };
}
