{
  den.aspects.greetd.nixos =
    {
      config,
      lib,
      ...
    }:
    {
      services.greetd =
        let
          session = {
            command = "${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop";
            user = "amadejk";
          };
        in
        {
          enable = true;
          settings = {
            terminal.vt = 1;
            default_session = session;
            initial_session = session;
          };
        };

      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        greetd-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
    };
}
