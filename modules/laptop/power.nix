# `power` aspect (Linux/NixOS): laptop power management — power-profiles-daemon,
# upower, suspend on power key. Replaces system/services/power.nix.
{
  den.aspects.power.nixos = {
    services = {
      logind.settings.Login.HandlePowerKey = "suspend";

      power-profiles-daemon.enable = true;

      upower.enable = true;
    };
  };
}
