# `printing` aspect (Linux/NixOS): CUPS printing.
# Replaces system/services/printing.nix.
{
  den.aspects.printing.nixos = {
    services.printing = {
      enable = true;
    };
  };
}
