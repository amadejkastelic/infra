# The `office` aspect (home-manager, Linux desktop).
# Converted from home/programs/office/{default,zathura}.nix.
{
  den.aspects.office.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        onlyoffice-desktopeditors
      ];

      programs.zathura = {
        enable = true;
      };
    };
}
