{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ./network.nix
    ./openrazer.nix
    ./immich.nix
    ./jellyfin.nix
    ./nvidia.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.hostName = "razer";

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
}
