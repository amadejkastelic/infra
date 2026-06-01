{
  den.aspects.databases.nixos =
    {
      pkgs,
      config,
      ...
    }:
    {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };

      services.mysqlBackup = {
        enable = true;

        # Every day at 1:15 AM
        calendar = "01:15:00";

        compressionAlg = "zstd";
        compressionLevel = 6;

        location = "${config.nas.backupDir}/mysql";
      };

      services.postgresql.enable = true;

      services.postgresqlBackup = {
        enable = true;
        backupAll = true;

        # Every day at 1 AM
        startAt = "*-*-* 01:00:00";
        compression = "zstd";

        location = "${config.nas.backupDir}/postgresql";
      };
    };
}
