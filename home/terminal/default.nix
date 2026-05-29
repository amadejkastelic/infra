{ config, ... }:
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

  # add environment variables
  home.sessionVariables = {
    # clean up ~
    LESSHISTFILE = "${cache}/less/history";
    LESSKEY = "${conf}/less/lesskey";

    WINEPREFIX = "${data}/wine";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";

    # auto-run programs using nix-index-database
    NIX_AUTO_RUN = "1";

    # Secrets
    CODEBERG_TOKEN = "$(cat ${config.sops.secrets.codeberg-token.path})";
    GITHUB_TOKEN = "$(cat ${config.sops.secrets.github-token.path})";
    Z_AI_API_KEY = "$(cat ${config.sops.secrets.z-ai-api-token.path})";
  };

  sops.secrets = {
    codeberg-token = { };
    github-token = { };
    z-ai-api-token = { };
  };
}
