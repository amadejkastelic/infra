{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./openrgb
    ./thermal-fix.nix
  ];

  services.scx = {
    enable = true;
    package = pkgs.scx.full;
    scheduler = "scx_lavd";
  };

  environment.systemPackages = with pkgs; [
    pcscliteWithPolkit
  ];

  hardware = {
    opentabletdriver.enable = true;
  };

  networking.hostName = "ryzen";
  networking.networkmanager.insertNameservers = [ "192.168.1.8" ];

  security.tpm2.enable = true;

  # Windows dual-boot time fix
  time.hardwareClockInLocalTime = true;

  services = {
    fstrim.enable = true;
  };
}
