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
  imports = [
    ./agents
    ./programs
    ./shell
  ];

  home.sessionVariables = {
    LESSHISTFILE = "${cache}/less/history";
    LESSKEY = "${conf}/less/lesskey";

    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";

    NIX_AUTO_RUN = "1";

    CODEBERG_TOKEN = "$(cat ${config.sops.secrets.codeberg-token.path})";
    GITHUB_TOKEN = "$(cat ${config.sops.secrets.github-token.path})";
    Z_AI_API_KEY = "$(cat ${config.sops.secrets.z-ai-api-token.path})";
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
}
