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
