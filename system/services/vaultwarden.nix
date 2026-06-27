{ config, ... }:
{
  homelab.subdomains = [ "vaultwarden" ];
  services.vaultwarden = {
    enable = true;
    nginx = {
      enable = true;
      hostName = "vaultwarden.${config.homelab.domain}";
    };

    environmentFile = config.sops.secrets.vaultwarden-env.path;

    dbBackend = "sqlite";
    backupDir = "${config.nas.backupDir}/vaultwarden/";

    config = {
      domain = "https://vaultwarden.${config.homelab.domain}";
      signupsAllowed = false;
      showPasswordHint = false;

      rocketAddress = "127.0.0.1";
      rocketPort = 8222;
      rocketLog = "critical";

      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";
      SMTP_FROM = "amadejkastelic7@gmail.com";
      SMTP_FROM_NAME = "Vaultwarden";
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
