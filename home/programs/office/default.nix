{ pkgs, lib, ... }:
{
  imports = lib.optionals (!pkgs.stdenv.isDarwin) [ ./zathura.nix ];

  home.packages = with pkgs; [
    onlyoffice-desktopeditors
  ];
}
