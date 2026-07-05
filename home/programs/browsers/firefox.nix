{
  pkgs,
  inputs,
  ...
}:
let
  base = import ./base.nix { inherit pkgs inputs; };
in
{
  programs.firefox = {
    enable = true;
    inherit (base) policies;
    profiles.default = base.profile;
  };

  catppuccin.firefox.enable = true;
}
