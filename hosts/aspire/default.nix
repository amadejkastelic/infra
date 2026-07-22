{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./cpu.nix
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  networking.hostName = "aspire";

  services.fstrim.enable = true;

  powerManagement.enable = true;
}
