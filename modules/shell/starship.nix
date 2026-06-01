{
  den.aspects.starship.homeManager =
    { config, ... }:
    {
      home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

      programs.starship = {
        enable = true;
        enableNushellIntegration = config.programs.nushell.enable;
        enableZshIntegration = config.programs.zsh.enable;

        settings = {
          character = {
            success_symbol = "[›](bold green)";
            error_symbol = "[›](bold red)";
          };

          git_status = {
            deleted = "✗";
            modified = "✶";
            staged = "✓";
            stashed = "≡";
          };

          nix_shell = {
            symbol = " ";
            heuristic = true;
          };
        };
      };

      catppuccin.starship.enable = true;
    };
}
