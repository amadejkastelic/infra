{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    nvidiaSettings = false;
  };

  systemd.services.nvidia-persistenced.environment = {
    LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
  };
}
