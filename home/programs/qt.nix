{ pkgs, lib, ... }:
{
  qt.enable = lib.mkIf (!pkgs.stdenv.isDarwin) true;
}
