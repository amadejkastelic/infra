{
  config,
  pkgs,
  inputs,
  self,
  ...
}:
let
  zAiApiKeyHelper = pkgs.writeShellScript "cloudcli-z-ai-api-key" ''
    exec ${pkgs.coreutils}/bin/cat ${config.sops.secrets."z_ai/api_token".path}
  '';
in
{
  services.cloudcli = {
    enable = true;

    package = self.packages.${pkgs.stdenv.hostPlatform.system}.cloudcli;
    claudePackage = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;

    repoUrl = "https://github.com/amadejkastelic/nixos-config.git";
    gitUserName = "Amadej Kastelic";
    gitUserEmail = "amadejkastelic7@gmail.com";
    githubTokenFile = config.sops.secrets."github/infra_api_token".path;
    apiKeyFile = config.sops.secrets."z_ai/api_token".path;

    extraPackages = [
      pkgs.nix
      pkgs.treefmt
      pkgs.nixfmt-rfc-style
    ];

    settings = {
      includeCoAuthoredBy = false;
      apiKeyHelper = "${zAiApiKeyHelper}";
      env = {
        ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
        ANTHROPIC_MODEL = "glm-5.3[1m]";
        ANTHROPIC_SMALL_FAST_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.3[1m]";
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        API_TIMEOUT_MS = "3000000";
      };
    };

    userInstructions = ''
      # Git workflow

      - Never commit to main. Start every task with a fresh branch (c/<short-slug>) off the latest main.
      - One logical change per commit. Subject format: `area: imperative summary`, where area is the top-level path of the change, e.g. `pkgs/cloudcli: add package`, `modules/services/grafana: fix x`, `hosts/razer: enable y`.
      - No Co-Authored-By or Generated-with footers in commit messages.
      - Run treefmt before committing; catch eval errors with `nix flake check --no-build`. The full `nix flake check` runs in CI on the PR — wait for it to pass before asking for review.
      - When the task is done: push the branch and open a PR with `gh pr create`. Do not merge it yourself; the owner reviews and merges.
      - Deployment is not your job: merged changes reach hosts via the upgrade-host workflow. Never run nixos-rebuild, just, or switch-to-configuration on this machine.
      - Never read or write any secrets.yaml; sops changes belong to the owner.
    '';
  };

  sops.secrets = {
    "z_ai/api_token".owner = config.services.cloudcli.user;
    "github/infra_api_token".owner = config.services.cloudcli.user;
  };
}
