# `thunar` aspect (Linux/NixOS): Thunar file manager + plugins + xfconf/gvfs/tumbler.
# Replaces system/programs/thunar.nix.
{
  den.aspects.thunar.nixos =
    { pkgs, ... }:
    {
      programs.thunar = {
        enable = true;

        plugins = with pkgs.xfce; [
          thunar-volman
          thunar-archive-plugin
          thunar-media-tags-plugin
        ];
      };

      environment.systemPackages = [ pkgs.xarchiver ];

      programs.xfconf.enable = true;
      services.gvfs.enable = true;
      services.tumbler.enable = true;
    };
}
