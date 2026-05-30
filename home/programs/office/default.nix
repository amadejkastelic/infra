{ pkgs, ... }:
{
  imports = [ ./zathura.nix ];

  home.packages = with pkgs; [
    onlyoffice-desktopeditors
  ];
}
