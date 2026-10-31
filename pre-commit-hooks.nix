{ inputs, ... }:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings = {
        excludes = [ "flake.lock" ];

        hooks = {
          actionlint = {
            enable = true;
            extraPackages = [ pkgs.shellcheck ];
          };
          nixfmt.enable = true;
          prettier = {
            enable = true;
            excludes = [
              ".js"
              ".md"
              ".ts"
            ];
          };
        };
      };
    };
}
