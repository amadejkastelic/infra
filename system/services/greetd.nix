{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --asterisks --cmd '${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop'";
      };
    };
  };

  security.pam.services = {
    greetd = {
      enableGnomeKeyring = true;
      yubicoAuth = false;
    };
    greetd-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };
}
