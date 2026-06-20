{ config, lib, ... }:
{
  services.postgresql.enable = true;

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;

    # Every day at 1 AM
    startAt = "*-*-* 01:00:00";
    compression = "zstd";

    location = "${config.nas.backupDir}/postgresql";
  };

  users.users.postgres_monitor = {
    isSystemUser = true;
    group = "postgres_monitor";
    home = "/var/empty";
    createHome = false;
  };
  users.groups.postgres_monitor = { };

  services.postgresql.ensureUsers = [ { name = "postgres_monitor"; } ];

  systemd.services.postgresql.postStart = lib.mkAfter ''
    ${config.services.postgresql.package}/bin/psql -tAc "GRANT pg_monitor TO postgres_monitor;" || true
  '';
}
