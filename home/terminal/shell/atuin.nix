{ config, ... }:
{
  programs.atuin = {
    enable = true;
    daemon.enable = true;

    enableNushellIntegration = config.programs.nushell.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}
