{
  pkgs,
  inputs,
  ...
}:
let
  base = import ./base.nix { inherit pkgs inputs; };
in
{
  imports = [ inputs.zen-browser.homeModules.twilight ];

  programs.zen-browser = {
    enable = true;
    inherit (base) policies;
    profiles.default = base.profile;
  };
}
