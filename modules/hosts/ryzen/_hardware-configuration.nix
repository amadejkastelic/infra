{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

    kernelModules = [
      "kvm-amd"
      "amdgpu" # https://github.com/ollama/ollama/issues/11916
    ];

    kernelParams = [
      "acpi_enforce_resources=lax"
      "mitigations=off"
      "audit=0"
      "usbcore.autosuspend=-1"
      "ipv6.disable=1" # Disable IPv6 - slow ghcr downloads
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5e8d4669-1563-49cd-9d94-657e99402fd8";
    fsType = "ext4";
  };

  boot.initrd.luks.fido2 = {
    enable = true;
    device = "836e758a-4fe0-4e78-a965-edfcf1f1445a";
    extraOpts = [ "timeout=0" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1DD5-C2F3";
    fsType = "vfat";
  };

  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-label/HDD";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/mnt/ssd1" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/3597ecc0-1fed-4075-bae0-99a88bde0554";
      randomEncryption = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
