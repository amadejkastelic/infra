# The `playerctl` aspect (home-manager, Linux desktop).
# Converted from home/services/media/playerctl.nix.
{
  den.aspects.playerctl.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.playerctl ];

      services.playerctld.enable = true;
    };
}
