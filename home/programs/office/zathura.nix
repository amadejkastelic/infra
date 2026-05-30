{ pkgs, lib, ... }:
{
  programs.zathura = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
  };
}
