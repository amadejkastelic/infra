{ config, ... }:
{
  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning = {
      enable = true;

      environment = {
        MPLCONFIGDIR = "/var/lib/immich/.config/matplotlib";
      };
    };

    nginx = {
      enable = true;
      hostName = "immich.amadejk.com";
    };

    port = 2283;

    mediaLocation = "${config.nas.dataDir}/photos";

    database = {
      enable = true;
    };
  };

  # Hardware acceleration
  users.users."${config.services.immich.user}".extraGroups = [
    "video"
    "render"
  ];

  systemd.tmpfiles.settings."immich" = {
    "${config.services.immich.mediaLocation}".d = {
      user = config.services.immich.user;
      group = config.services.immich.group;
      mode = "0775";
    };
  };
}
