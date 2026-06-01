# `dconf` aspect (Linux/NixOS): top-level desktop program toggles.
# Replaces the leaf config in system/programs/default.nix.
{
  den.aspects.dconf.nixos = {
    programs = {
      # make HM-managed GTK stuff work
      dconf.enable = true;

      seahorse.enable = false;
    };
  };
}
