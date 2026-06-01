# `nas` aspect (Linux/NixOS): the NAS server — NFS server exports, smartd disk
# monitoring (mail via msmtp), and ZFS (trim, scrub, zed mail notifications).
# Replaces system/services/nas/{default,nfs,smartd,zfs}.nix and hosts/oblak/nfs.nix.
{
  den.aspects.nas.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ports = [
        2049
        config.services.nfs.server.mountdPort
        config.services.nfs.server.lockdPort
      ];
    in
    {
      # NFS server
      services.nfs.server = {
        enable = true;

        mountdPort = 4002;
        lockdPort = 4001;

        exports = ''
          /storage/data    *(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)
          /storage/media   *(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)
          /storage/backups *(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)
        '';
      };

      networking.firewall.allowedTCPPorts = ports;
      networking.firewall.allowedUDPPorts = ports;

      services.rpcbind.enable = true;

      # smartd disk health monitoring
      services.smartd = {
        enable = true;
        autodetect = true;

        notifications = {
          x11.enable = false;

          mail = {
            enable = true;
            mailer = lib.getExe pkgs.msmtp;
          };
        };
      };

      # ZFS
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

      boot.zfs.forceImportAll = false;
    };
}
