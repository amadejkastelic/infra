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
