# `noisetorch` aspect (Linux/NixOS): NoiseTorch noise suppression.
# Replaces system/programs/noisetorch.nix.
{
  den.aspects.noisetorch.nixos = {
    programs.noisetorch = {
      enable = true;
    };
  };
}
