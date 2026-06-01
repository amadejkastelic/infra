# The `atuin` aspect (home-manager). Converted from home/terminal/shell/atuin.nix.
{
  den.aspects.atuin.homeManager =
    { config, pkgs, ... }:
    {
      programs.atuin = {
        enable = true;
        daemon.enable = !pkgs.stdenv.isDarwin;

        enableNushellIntegration = config.programs.nushell.enable;
        enableZshIntegration = config.programs.zsh.enable;
      };
    };
}
