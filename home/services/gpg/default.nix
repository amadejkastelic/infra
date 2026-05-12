{ pkgs, config, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
    enableSshSupport = true;
    enableScDaemon = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Using gpg instead
  services.ssh-agent.enable = false;

  programs.gpg.enable = true;
}
