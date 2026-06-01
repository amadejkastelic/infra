# The `networkmanager` aspect (home-manager, Linux desktop).
# Converted from home/services/networkmanager/default.nix. Provides the
# NetworkManager and Blueman tray applets.
{
  den.aspects.networkmanager.homeManager =
    {
      lib,
      ...
    }:
    {
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Unit.After = lib.mkForce "graphical-session.target";

      services.blueman-applet.enable = true;
      systemd.user.services.blueman-applet.Unit.After = lib.mkForce "graphical-session.target";
    };
}
