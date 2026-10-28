{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.claude-web;

  claudeSettings = pkgs.writeText "claude-web-settings.json" (builtins.toJSON cfg.settings);

  vhostName = "${cfg.subdomain}.${config.homelab.domain}";

  basePackages = with pkgs; [
    nodejs
    git
    gh
    coreutils
    gnugrep
    findutils
    gnused
    gawk
    diffutils
    patch
    jq
    curl
    less
    ripgrep
    procps
    util-linux
    file
    gnutar
    gzip
    xz
    unzip
  ];
in
{
  options.services.claude-web = {
    enable = lib.mkEnableOption "CloudCLI web interface for Claude Code";

    package = lib.mkOption {
      type = lib.types.package;
      description = "CloudCLI package to run";
    };

    claudePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.claude-code;
      description = "Claude Code CLI exposed to sessions";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3004;
      description = "Port CloudCLI binds to on localhost";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "claude-web";
      description = "User to run CloudCLI as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "claude-web";
      description = "Group to run CloudCLI as";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/claude-web";
      description = "State directory holding the claude config and git checkout";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "vibe";
      description = "homelab subdomain for the nginx vhost";
    };

    repoUrl = lib.mkOption {
      type = lib.types.str;
      description = "git remote cloned into the workspace";
    };

    gitUserName = lib.mkOption {
      type = lib.types.str;
      description = "git commit author name";
    };

    gitUserEmail = lib.mkOption {
      type = lib.types.str;
      description = "git commit author email";
    };

    githubTokenFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing a GitHub token used for gh auth";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Claude Code settings.json written for the service user";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages exposed to sessions and the web terminal";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      shell = pkgs.bashInteractive;
      packages = basePackages;
    };
    users.groups.${cfg.group} = { };

    homelab.subdomains = [ cfg.subdomain ];

    services.nginx.virtualHosts.${vhostName} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    systemd.services.claude-web-init = {
      description = "Claude web workspace bootstrap";
      wantedBy = [ "multi-user.target" ];
      before = [ "claude-web.service" ];
      after = [
        "sops-nix.service"
        "network-online.target"
        "blocky.service"
      ];
      wants = [ "network-online.target" ];
      unitConfig.ConditionPathExists = [ cfg.githubTokenFile ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = builtins.baseNameOf cfg.stateDir;
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      path = [
        pkgs.git
        pkgs.gh
      ];
      script = ''
        mkdir -p "$HOME/.claude"
        install -m 600 ${claudeSettings} "$HOME/.claude/settings.json"

        ${pkgs.gh}/bin/gh auth login --with-token < ${cfg.githubTokenFile}
        ${pkgs.gh}/bin/gh auth setup-git

        if [ ! -e "$HOME/dotfiles/.git" ]; then
          ${pkgs.git}/bin/git clone ${cfg.repoUrl} "$HOME/dotfiles"
        else
          ${pkgs.git}/bin/git -C "$HOME/dotfiles" fetch --prune origin || true
        fi

        ${pkgs.git}/bin/git -C "$HOME/dotfiles" config user.name "${cfg.gitUserName}"
        ${pkgs.git}/bin/git -C "$HOME/dotfiles" config user.email "${cfg.gitUserEmail}"
      '';
    };

    systemd.services.claude-web = {
      description = "CloudCLI web interface for Claude Code";
      wantedBy = [ "multi-user.target" ];
      after = [
        "claude-web-init.service"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      requires = [ "claude-web-init.service" ];
      unitConfig.ConditionPathExists = [ "${cfg.stateDir}/dotfiles/.git" ];
      environment = {
        HOST = "127.0.0.1";
        PORT = toString cfg.port;
        HOME = cfg.stateDir;
      };
      path = [
        cfg.package
        cfg.claudePackage
      ]
      ++ basePackages
      ++ cfg.extraPackages;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = builtins.baseNameOf cfg.stateDir;
        WorkingDirectory = "${cfg.stateDir}/dotfiles";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
