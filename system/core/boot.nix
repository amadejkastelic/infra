{ config, ... }:
{
  boot = {
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
      # systemd-boot on UEFI
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
}
