{
  den.aspects.openrgb.nixos =
    { pkgs, ... }:
    {
      services.hardware.openrgb.package = pkgs.local.openrgb-rc;
    };
}
