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
