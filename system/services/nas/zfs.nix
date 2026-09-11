{ lib, pkgs, ... }:
{
  services.zfs = {
    trim.enable = true;

    autoScrub = {
      enable = true;
      interval = "weekly";
    };

    zed = {
      enableMail = true;
      settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";

        ZED_EMAIL_PROG = lib.getExe pkgs.msmtp;
        ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = false;
      };
    };
  };

  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };
}
