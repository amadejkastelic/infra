{
  den.aspects.shell.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      data = config.xdg.dataHome;
      conf = config.xdg.configHome;
      cache = config.xdg.cacheHome;
    in
    {
      home.sessionVariables = {
        LESSHISTFILE = "${cache}/less/history";
        LESSKEY = "${conf}/less/lesskey";

        EDITOR = "nvim";
        DIRENV_LOG_FORMAT = "";

        NIX_AUTO_RUN = "1";
      }
      // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
        WINEPREFIX = "${data}/wine";
        XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
      };

      sops.secrets = {
        codeberg-token = { };
        github-token = { };
        z-ai-api-token = { };
      };
    };
}
