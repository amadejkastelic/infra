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
