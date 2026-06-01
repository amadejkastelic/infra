# The `macos-security` aspect: Touch ID for sudo via pam.
# Replaces the security.pam.services.sudo_local block from
# system/darwin/default.nix.
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
