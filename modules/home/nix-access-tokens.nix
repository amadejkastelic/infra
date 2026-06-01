# The `nix-access-tokens` aspect (home-manager).
# Converted from home/programs/nix.nix. Wires the SOPS nix access tokens file
# into nix.extraOptions.
{
  den.aspects.nix-access-tokens.homeManager =
    {
      config,
      ...
    }:
    {
      nix.extraOptions = ''
        # Include the SOPS file for Nix access tokens
        !include ${config.sops.secrets.nix-access-tokens.path}
      '';

      sops.secrets.nix-access-tokens = { };
    };
}
