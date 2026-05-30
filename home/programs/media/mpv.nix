{ pkgs, lib, ... }:
{
  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = lib.optionals (!pkgs.stdenv.isDarwin) [ pkgs.mpvScripts.mpris ];
  };
}
