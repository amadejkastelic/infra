{
  config,
  lib,
  ...
}:
let
  hasAuthKey = builtins.hasAttr "tailscale-auth-key" config.sops.secrets;
in
{
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = if hasAuthKey then config.sops.secrets.tailscale-auth-key.path else null;
    extraUpFlags = lib.optionals config.services.nginx.enable [
      "--accept-dns=false"
      "--advertise-routes=${config.homelab.lanCidr}"
    ];
  };
}
