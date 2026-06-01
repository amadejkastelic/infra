{
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "default";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/OpenRGB 0755 root root -"
    "L+ /var/lib/OpenRGB/default.orp - - - - ${./default.orp}"
  ];
}
