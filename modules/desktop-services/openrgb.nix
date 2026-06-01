# `openrgb` aspect (Linux/NixOS): OpenRGB using the custom openrgb-rc package.
# Replaces system/services/openrgb.nix.
{
  den.aspects.openrgb.nixos =
    { pkgs, ... }:
    {
      services.hardware.openrgb.package = pkgs.local.openrgb-rc;
    };
}
