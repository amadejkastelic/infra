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

    settings = {
      includeCoAuthoredBy = false;
      apiKeyHelper = "${zAiApiKeyHelper}";
      env = {
        ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.3[1m]";
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        API_TIMEOUT_MS = "3000000";
      };
    };
  };

  sops.secrets = {
    "z_ai/api_token".owner = config.services.cloudcli.user;
    "github/infra_api_token".owner = config.services.cloudcli.user;
  };
}
