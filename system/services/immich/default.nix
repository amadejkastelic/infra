{ config, ... }:
{
  imports = [ ./proxy.nix ];

  homelab.subdomains = [ "immich" ];
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
      hostName = "immich.${config.homelab.domain}";
    };

    port = 2283;

    mediaLocation = "${config.nas.dataDir}/photos";

    database = {
      enable = true;
    };

    settings = {
      ffmpeg = {
        accel = "nvenc";
        accelDecode = true;
        acceptedVideoCodecs = [ "hevc" ];
        crf = 28;
        preset = "medium";
        targetResolution = "original";
        targetVideoCodec = "hevc";
      };
      machineLearning.urls = [ "http://localhost:3003" ];
      newVersionCheck.enabled = false;
      notifications.smtp = {
        enabled = true;
        from = config.programs.msmtp.accounts.default.from;
        transport = {
          inherit (config.programs.msmtp.accounts.default) host port;
          username = config.programs.msmtp.accounts.default.from;
          password._secret = config.sops.secrets.gmail-password.path;
        };
      };
      server.externalDomain = "https://gallery.${config.homelab.domain}";
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
