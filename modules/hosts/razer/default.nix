{ inputs, den, ... }:
{
  # server: OS user only, no home-manager (classes = []).
  den.hosts.x86_64-linux.razer.users.amadejk.classes = [ ];

  den.aspects.razer = {
    provides.to-users.includes = with den.aspects; [
      base
      secrets
      network
      amadejk
      nfs-mount
      docker
      msmtp
      arr
      jellyseerr
      qbittorrent
      flaresolverr
      blocky
      dashboard
      databases
      grabby
      immich
      jellyfin
      nginx
      tailscale-tls
      vaultwarden
    ];

    nixos =
      {
        modulesPath,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.disko
          ./_disk-config.nix
          ./_hardware-configuration.nix
          ./_openrazer.nix
          ./_immich.nix
          ./_jellyfin.nix
          ./_nvidia.nix
        ];

        networking.hostName = "razer";
        nixpkgs.hostPlatform = "x86_64-linux";

        sops.defaultSopsFile = ./secrets.yaml;

        boot.loader.grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
        services.openssh.enable = true;

        environment.systemPackages = map lib.lowPrio [
          pkgs.curl
          pkgs.gitMinimal
        ];

        services.fstrim.enable = true;

        # Laptop server, disable lid and power key
        services.logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandlePowerKey = "ignore";
          HandleSuspendKey = "ignore";
          HandleHibernateKey = "ignore";
          IdleAction = "ignore";
          IdleActionSec = "0sec";
        };

        powerManagement.enable = false;
        systemd.targets = {
          sleep.enable = false;
          suspend.enable = false;
          hibernate.enable = false;
        };

        # Turn off screen after 10 seconds of inactivity
        boot.kernelParams = [ "consoleblank=10" ];
      };
  };
}
