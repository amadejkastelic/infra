# `idescriptor` aspect (Linux/NixOS): idescriptor program for the amadejk user.
# Replaces system/programs/idescriptor.nix.
{
  den.aspects.idescriptor.nixos = {
    programs.idescriptor = {
      enable = true;
      users = [ "amadejk" ];
    };
  };
}
