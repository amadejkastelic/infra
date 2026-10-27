{
  pkgs,
  config,
  lib,
  inputs,
  self,
  ...
}:
let
  zAiApiKeyHelper = pkgs.writeShellScript "claude-z-ai-api-key" ''
    exec ${pkgs.coreutils}/bin/cat ${config.sops.secrets.z-ai-api-token.path}
  '';
in
{
  programs.claude-code = {
    enable = true;

    package = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;

    plugins = {
      code-review = "${
        self.packages.${pkgs.stdenv.hostPlatform.system}.anthropic-plugins-official
      }/plugins/code-review";
      mattpocock-skills = self.packages.${pkgs.stdenv.hostPlatform.system}.mattpocock-skills;
    };

    skills = {
      skill-creator = "${
        self.packages.${pkgs.stdenv.hostPlatform.system}.anthropic-skills
      }/skills/skill-creator";
    };

    lspServers = {
      rust-analyzer = {
        command = lib.getExe pkgs.rust-analyzer;
        extensionToLanguage.".rs" = "rust";
      };
      gopls = {
        command = lib.getExe pkgs.gopls;
        extensionToLanguage.".go" = "go";
      };
      nixd = {
        command = lib.getExe pkgs.nixd;
        extensionToLanguage.".nix" = "nix";
      };
      starpls = {
        command = lib.getExe pkgs.starpls;
        extensionToLanguage = {
          ".bzl" = "starlark";
          ".star" = "starlark";
          ".bazel" = "starlark";
        };
      };
    };

    mcpServers = config.programs.mcp.servers;

    settings = {
      includeCoAuthoredBy = false;
      enableAllProjectMcpServers = true;
      showClearContextOnPlanAccept = true;
      apiKeyHelper = "${zAiApiKeyHelper}";
      outputStyle = "concise";
      tui = "default";

      env = {
        ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.3-flash";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.3[1m]";
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000";
        CLAUDE_CODE_AUTO_MODE_SERVER = "0";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        API_TIMEOUT_MS = "3000000";
      };
    };
  };

  sops.secrets.z-ai-api-token = { };
}
