{
  pkgs,
  config,
  self,
  ...
}:
# nix tooling
{
  home.packages = with pkgs; [
    nixd
    nixfmt
    deadnix
    statix
    self.packages.${pkgs.stdenv.hostPlatform.system}.repl
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;
    silent = true;
  };
}
