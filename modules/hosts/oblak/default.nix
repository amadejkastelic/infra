# oblak — x86_64 NAS (ZFS, NFS server, ugreen LED control).
{ inputs, den, ... }:
{
  # NAS: OS user only, no home-manager.
  den.hosts.x86_64-linux.oblak.users.amadejk.classes = [ ];

  den.aspects.oblak = {
    provides.to-users.includes = with den.aspects; [
      base
      secrets
      network
      amadejk
      msmtp
      nas
      ugreen-leds
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
        ];

        networking.hostName = "oblak";
        nixpkgs.hostPlatform = "x86_64-linux";

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
        powerManagement.enable = false;
      };
  };
}
