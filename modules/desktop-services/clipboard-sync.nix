# `clipboard-sync` aspect (Linux/NixOS): cross-host clipboard syncing.
# Replaces system/services/clipboard-sync.nix.
{ inputs, ... }:
{
  den.aspects.clipboard-sync.nixos = {
    imports = [ inputs.clipboard-sync.nixosModules.default ];

    services.clipboard-sync.enable = true;
  };
}
