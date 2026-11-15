{
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "white";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/OpenRGB/profiles 0755 root root -"
    "L+ /var/lib/OpenRGB/profiles/white.json - - - - ${./white.json}"
  ];
}
