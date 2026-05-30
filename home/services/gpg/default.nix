{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
    enableSshSupport = true;
    enableScDaemon = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;
  };

  services.ssh-agent.enable = false;

  programs.gpg.enable = true;
}
