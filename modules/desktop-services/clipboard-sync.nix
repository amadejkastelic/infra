{ inputs, ... }:
{
  den.aspects.clipboard-sync.nixos = {
    imports = [ inputs.clipboard-sync.nixosModules.default ];

    services.clipboard-sync.enable = true;
  };
}
