{
  den.aspects.macos-security = {
    darwin = {
      security.pam.services.sudo_local = {
        enable = true;
        reattach = true;
        touchIdAuth = true;
      };
    };
  };
}
