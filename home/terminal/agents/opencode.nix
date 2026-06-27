{ config, ... }:
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      autoupdate = false;
      theme = "catppuccin";
      permission = {
        read = "allow";
        glob = "allow";
        grep = "allow";
        list = "allow";
        webfetch = "allow";
        websearch = "allow";
        edit = "ask";
        external_directory = "ask";
        doom_loop = "ask";
        skill = "allow";
        bash = {
          "*" = "ask";
          "git status" = "allow";
          "git status *" = "allow";
          "git diff" = "allow";
          "git diff *" = "allow";
          "git log" = "allow";
          "git log *" = "allow";
          "git show" = "allow";
          "git show *" = "allow";
          "git branch" = "allow";
          "git branch *" = "allow";
          "git remote" = "allow";
          "git remote *" = "allow";
          "git stash list" = "allow";
          "git stash list *" = "allow";
          "git blame *" = "allow";
          "git ls-files *" = "allow";
          "git rev-parse *" = "allow";
          "git config --get *" = "allow";
          "git describe *" = "allow";
          "git tag" = "allow";
          "git tag *" = "allow";
          "git ls-remote *" = "allow";
          "ls" = "allow";
          "ls *" = "allow";
          "ll" = "allow";
          "ll *" = "allow";
          "cat *" = "allow";
          "head *" = "allow";
          "tail *" = "allow";
          "less *" = "allow";
          "tree" = "allow";
          "tree *" = "allow";
          "file *" = "allow";
          "stat *" = "allow";
          "wc *" = "allow";
          "du *" = "allow";
          "df" = "allow";
          "df *" = "allow";
          "free" = "allow";
          "free *" = "allow";
          "pwd" = "allow";
          "whoami" = "allow";
          "id" = "allow";
          "id *" = "allow";
          "uname *" = "allow";
          "hostname" = "allow";
          "date" = "allow";
          "uptime" = "allow";
          "env" = "allow";
          "printenv *" = "allow";
          "find" = "allow";
          "find *" = "allow";
          "fd *" = "allow";
          "rg *" = "allow";
          "grep *" = "allow";
          "ag *" = "allow";
          "nix flake show" = "allow";
          "nix flake show *" = "allow";
          "nix flake metadata" = "allow";
          "nix flake metadata *" = "allow";
          "nix flake check" = "allow";
          "nix flake check *" = "allow";
          "nix flake archive --dry-run *" = "allow";
          "nix eval *" = "allow";
          "nix path-info *" = "allow";
          "nix hash *" = "allow";
          "nix profile list" = "allow";
          "nix-store --query *" = "allow";
          "nix-collect-garbage --dry-run *" = "allow";
          "just --list" = "allow";
          "just --list *" = "allow";
          "just -l" = "allow";
          "just --show *" = "allow";
          "just --summary" = "allow";
          "systemctl status *" = "allow";
          "systemctl list-*" = "allow";
          "systemctl list-* *" = "allow";
          "journalctl *" = "allow";
          "ip *" = "allow";
          "ss *" = "allow";
          "ps *" = "allow";
          "lsblk" = "allow";
          "lsblk *" = "allow";
          "lspci" = "allow";
          "lspci *" = "allow";
          "lsusb" = "allow";
          "lsusb *" = "allow";
          "mount" = "allow";
          "lsmod" = "allow";
          "treefmt" = "allow";
          "treefmt *" = "allow";
        };
      };
      default_agent = "plan";
      server = {
        port = 4096;
        hostname = "0.0.0.0";
      };
    };
  };

  sops.templates."opencode-auth.json" = {
    content = builtins.toJSON {
      zai-coding-plan = {
        type = "api";
        key = config.sops.placeholder.z-ai-api-token;
      };
      kimi-for-coding = {
        type = "api";
        key = config.sops.placeholder.kimi-api-token;
      };
    };
    path = "${config.xdg.dataHome}/opencode/auth.json";
  };

  sops.secrets = {
    z-ai-api-token = { };
    kimi-api-token = { };
    grafana-service-account-token = { };
  };
}
