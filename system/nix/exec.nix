{ inputs, ... }:
{
  imports = [ inputs.nix-exec.nixosModules.default ];

  programs.nix-exec = {
    enable = true;
    sandbox.timeout = "5m";
  };
}
