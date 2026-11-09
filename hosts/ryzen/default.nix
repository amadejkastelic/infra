{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./openrgb
    ./thermal-fix.nix
    ./workstation.nix
  ];

  services.scx-loader = {
    enable = false;
    schedsPackages = [ pkgs.scx.full ];
    config.default_sched = "scx_bpfland";
  };

  environment.systemPackages = with pkgs; [
    pcscliteWithPolkit
  ];

  hardware = {
    opentabletdriver.enable = true;
  };

  networking.hostName = "ryzen";
  networking.networkmanager.insertNameservers = [
    "192.168.1.8"
    "1.1.1.1"
    "8.8.8.8"
  ];

  security.tpm2.enable = true;

  time.hardwareClockInLocalTime = false;

  services = {
    fstrim.enable = true;
  };
}
