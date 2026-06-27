{ config, lib, ... }:
let
  port = toString config.services.forgejo.settings.server.HTTP_PORT;
  sshPort = 2222;

  keys = builtins.filter (
    k: !lib.hasInfix "github-actions" k && !lib.hasPrefix "sk-" k
  ) config.users.users.amadejk.openssh.authorizedKeys.keys;
in
{
  catppuccin.forgejo.enable = true;

  homelab.subdomains = [ "forgejo" ];

  services.forgejo = {
    enable = true;
    stateDir = "/var/lib/forgejo";

    database = {
      type = "postgres";
      name = "forgejo";
      user = "forgejo";
    };

    settings = {
      server = {
        DOMAIN = "forgejo.${config.homelab.domain}";
        ROOT_URL = "https://forgejo.${config.homelab.domain}";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3001;
        DISABLE_SSH = false;
        START_SSH_SERVER = true;
        SSH_PORT = sshPort;
        SSH_LISTEN_PORT = sshPort;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
      log.LEVEL = "Info";
    };

    dump = {
      enable = true;
      backupDir = "${config.nas.backupDir}/forgejo/";
      type = "tar.zst";
    };

    provision = {
      enable = true;
      adminUsername = "amadejkastelic";
      adminEmail = "amadejkastelic7@gmail.com";
      passwordFile = config.sops.secrets."forgejo/admin-password".path;
      sshKeys = keys;
    };
  };

  services.nginx.virtualHosts."forgejo.${config.homelab.domain}".locations."/" = {
    proxyPass = "http://127.0.0.1:${port}";
    proxyWebsockets = true;
  };

  networking.firewall.allowedTCPPorts = [ sshPort ];

  sops.secrets."forgejo/admin-password" = { };
}
