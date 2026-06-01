# Desktop boot aspects. Replaces system/core/boot.nix + system/core/lanzaboote.nix.
{ inputs, ... }:
{
  den.aspects.boot.nixos =
    { config, ... }:
    {
      boot = {
        bootspec.enable = true;

        initrd = {
          systemd.enable = true;
          supportedFilesystems = [
            "ext4"
            "ntfs"
          ];
        };

        binfmt.emulatedSystems = [
          "aarch64-linux"
          "armv7l-linux"
          "i686-linux"
          "riscv64-linux"
        ];

        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "systemd.show_status=auto"
          "rd.udev.log_level=3"
          "noresume"
        ];

        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = true;
            edk2-uefi-shell.enable = true;
            consoleMode = "max";
          };
        };

        plymouth.enable = true;

        tmp.cleanOnBoot = true;
      };

      environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
    };

  # Secure Boot via lanzaboote (overrides systemd-boot install).
  den.aspects.lanzaboote.nixos =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot = {
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        # we let lanzaboote install systemd-boot
        loader.systemd-boot.enable = lib.mkForce false;
      };

      environment.systemPackages = [ pkgs.sbctl ];
    };
}
