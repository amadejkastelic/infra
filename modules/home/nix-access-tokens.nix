{
  den.aspects.nix-access-tokens.homeManager =
    {
      config,
      ...
    }:
    {
      nix.extraOptions = ''
        !include ${config.sops.secrets.nix-access-tokens.path}
      '';

      sops.secrets.nix-access-tokens = { };
    };
}
