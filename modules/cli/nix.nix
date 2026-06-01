# The `nix-tools` aspect (home-manager). Nix tooling + direnv.
# Converted from home/terminal/programs/nix.nix.
{
  den.aspects.nix-tools.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        nixd
        nixfmt
        deadnix
        statix
        pkgs.local.repl
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableZshIntegration = config.programs.zsh.enable;
        enableNushellIntegration = config.programs.nushell.enable;
        silent = true;
      };
    };
}
