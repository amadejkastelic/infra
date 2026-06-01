# `gpg-system` aspect (Linux/NixOS): smartcard daemon, YubiKey udev + PAM u2f.
# Replaces system/services/gpg.nix.
{
  den.aspects.gpg-system.nixos =
    { pkgs, ... }:
    {
      services = {
        pcscd.enable = true;
        udev.packages = [ pkgs.yubikey-personalization ];

        /*
            udev.extraRules = ''
            ACTION=="remove",\
             ENV{ID_BUS}=="usb",\
             ENV{ID_MODEL_ID}=="0407",\
             ENV{ID_VENDOR_ID}=="1050",\
             ENV{ID_VENDOR}=="Yubico",\
             RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
          '';
        */
      };

      security.pam.services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };

      security.pam.yubico = {
        enable = true;
        mode = "challenge-response";
        id = [ "28059814" ];
      };
    };
}
