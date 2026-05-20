{ lib, inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  networking.hostId = "6736bb90";

  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelParams = [
      # 7 / 8 GiB for ARC
      "zfs.zfs_arc_max=${toString (7 * 1024 * 1024 * 1024)}"
    ];
  };

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "40G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          zfs_log = {
            name = "zfs-log";
            size = "8G";
          };
          zfs_cache = {
            name = "zfs-cache";
            size = "100%";
          };
        };
      };
    };

    disk = {
      hdd1 = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
      hdd2 = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
      hdd3 = {
        device = "/dev/sdc";
        type = "disk";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
      hdd4 = {
        device = "/dev/sdd";
        type = "disk";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
    };

    zpool.storage = {
      type = "zpool";
      mode = "raidz1";
      options = {
        ashift = "12";
        cachefile = "none";
      };
      rootFsOptions = {
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
      };
      mountOptions = [ "nofail" ];
      mountpoint = "/storage";

      postCreateHook = ''
        zpool add storage log /dev/disk/by-partlabel/disk-main-zfs-log
        zpool add storage cache /dev/disk/by-partlabel/disk-main-zfs-cache
      '';

      datasets = {
        media = {
          type = "zfs_fs";
          mountpoint = "/storage/media";
          mountOptions = [ "nofail" ];
          options = {
            compression = "lz4";
            recordsize = "1M";
          };
        };
        data = {
          type = "zfs_fs";
          mountpoint = "/storage/data";
          mountOptions = [ "nofail" ];
          options = {
            compression = "zstd";
          };
        };
        backups = {
          type = "zfs_fs";
          mountpoint = "/storage/backups";
          mountOptions = [ "nofail" ];
          options = {
            compression = "zstd";
          };
        };
      };
    };
  };
}
