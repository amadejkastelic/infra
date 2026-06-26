{ config, ... }:
{
  services.immich-public-proxy = {
    enable = true;
    port = 3002;
    immichUrl = "http://${config.services.immich.host}:${toString config.services.immich.port}";
  };

  systemd.services.immich-public-proxy.environment.PUBLIC_BASE_URL =
    "https://gallery.${config.homelab.domain}";
}
