# `nautilus` aspect (Linux/NixOS): GNOME Files + open-any-terminal + gvfs/sushi.
# Replaces system/programs/nautilus.nix.
{
  den.aspects.nautilus.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nautilus ];

      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
      };

      services = {
        gvfs.enable = true;
        gnome.sushi.enable = true;
      };
    };
}
