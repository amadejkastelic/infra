{ config, ... }:
{
  services.vaultwarden = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "vaultwarden.amadejk.com";
    };

    environmentFile = config.sops.secrets.vaultwarden-env.path;

    dbBackend = "sqlite";
    backupDir = "${config.nas.backupDir}/vaultwarden/";

    config = {
      domain = "https://vaultwarden.amadejk.com";
      signupsAllowed = false;
      showPasswordHint = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 8222;
      rocketLog = "critical";
    };
  };

  sops.secrets.vaultwarden-env =
    let
      serviceConfig = config.systemd.services.vaultwarden.serviceConfig;
    in
    {
      owner = serviceConfig.User;
      group = serviceConfig.Group;
    };
}
