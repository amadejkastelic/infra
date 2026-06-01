# `location` aspect (Linux/NixOS): geoclue2 location provider.
# Replaces system/services/location.nix.
{
  den.aspects.location.nixos = {
    # enable location service
    location.provider = "geoclue2";

    # provide location
    services.geoclue2.enable = true;
  };
}
