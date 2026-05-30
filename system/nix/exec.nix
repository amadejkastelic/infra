{ inputs, ... }:
{
  imports = [ inputs.nix-exec.nixosModules.default ];

  programs.nix-exec = {
    enable = true;
    settings.sandbox.timeout = "5m";
  };
}
