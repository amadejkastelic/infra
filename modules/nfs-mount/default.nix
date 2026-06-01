{
  den.aspects.nfs-mount.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.nas;

      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=600"
        "_netdev"
      ];
    in
    {
      options.nas = {
        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/nas-data";
          description = "Mount point for NAS data directory";
        };

        mediaDir = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/nas-media";
          description = "Mount point for NAS media directory";
        };

        backupDir = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/nas-backups";
          description = "Mount point for NAS backups directory";
        };
      };

      config = {
        fileSystems = {
          "${cfg.dataDir}" = {
            device = "oblak.local:/storage/data";
            fsType = "nfs";
            options = options;
          };

          "${cfg.mediaDir}" = {
            device = "oblak.local:/storage/media";
            fsType = "nfs";
            options = options;
          };

          "${cfg.backupDir}" = {
            device = "oblak.local:/storage/backups";
            fsType = "nfs";
            options = options;
          };
        };
      };
    };
}
