# The `carapace` aspect (home-manager). Converted from home/terminal/shell/carapace.nix.
{
  den.aspects.carapace.homeManager =
    { config, ... }:
    {
      programs.carapace = {
        enable = true;

        enableNushellIntegration = config.programs.nushell.enable;
        enableZshIntegration = config.programs.zsh.enable;
      };
    };
}
