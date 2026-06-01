# The `git` aspect (home-manager). Converted from home/terminal/programs/git.nix.
{
  den.aspects.git.homeManager =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.gh ];

      # enable scrolling in git diff
      home.sessionVariables.DELTA_PAGER = "less -R";

      programs.delta.enable = true;

      programs.git = {
        enable = true;

        settings = {
          user = {
            email = "amadejkastelic7@gmail.com";
            name = "Amadej Kastelic";
          };

          diff.colorMoved = "default";
          merge.conflictstyle = "diff3";

          gpg = {
            ssh.defaultKeyCommand = "sh -c 'echo key::$(ssh-add -L | head -1)'";
            commit.gpgsign = true;
          };

          aliases = {
            unstage = "reset";
          };
        };

        ignores = [
          "*~"
          "*.swp"
          "*result*"
          ".direnv"
          "node_modules"
        ];

        signing = {
          format = "ssh";
          key = "${config.home.homeDirectory}/.ssh/id_ed25519";
          signByDefault = true;
        };
      };
    };
}
