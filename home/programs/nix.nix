{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.nix-access-tokens = { };

  xdg.configFile."nix/nix.conf" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
  };

  nix.extraOptions = lib.mkIf (!pkgs.stdenv.isDarwin) ''
    !include ${config.sops.secrets.nix-access-tokens.path}
  '';
}
