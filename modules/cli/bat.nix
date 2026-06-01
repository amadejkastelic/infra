# The `bat` aspect (home-manager). Converted from home/terminal/programs/bat.nix.
{
  den.aspects.bat.homeManager = {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };
}
