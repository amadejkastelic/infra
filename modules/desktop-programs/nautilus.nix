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
