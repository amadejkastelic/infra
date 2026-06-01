# `flaresolverr` aspect (Linux/NixOS): FlareSolverr proxy (used by Prowlarr to
# bypass Cloudflare).
# Replaces system/services/arr/flaresolverr.nix.
{
  den.aspects.flaresolverr.nixos = {
    services.flaresolverr = {
      enable = true;
      port = 8191;
    };
  };
}
