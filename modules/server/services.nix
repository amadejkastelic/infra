# `server-services` aspect (Linux/NixOS): misc base server services — dbus broker
# and profile-sync-daemon.
# Replaces system/services/default.nix.
{
  den.aspects.server-services.nixos = {
    services = {
      dbus.implementation = "broker";

      # profile-sync-daemon
      psd = {
        enable = true;
        resyncTimer = "10m";
      };
    };
  };
}
