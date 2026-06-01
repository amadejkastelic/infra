{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nixd
          nixfmt
          nodejs-slim
          git
          config.packages.repl
        ];
        name = "dots";
        DIRENV_LOG_FORMAT = "";
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
}
