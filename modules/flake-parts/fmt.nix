# Formatting + git hooks (replaces top-level pre-commit-hooks.nix + treefmt.toml).
{ inputs, ... }:
{
  flake-file.inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      pre-commit = {
        settings.excludes = [ "flake.lock" ];

        settings.hooks = {
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
