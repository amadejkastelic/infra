# `nginx` aspect (Linux/NixOS): nginx reverse proxy with tailscale auth.
# Replaces the native nginx config of system/services/nginx.nix.
{
  den.aspects.nginx.nixos =
    { config, ... }:
    let
      hostName = config.networking.hostName;
    in
    {
      services.nginx = {
        enable = true;
        enableReload = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;

        tailscaleAuth = {
          enable = true;
          virtualHosts = [ hostName ];
        };
      };
    };
}
