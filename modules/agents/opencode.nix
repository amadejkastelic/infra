# The `opencode` aspect (home-manager). Converted from home/terminal/agents/opencode.nix.
{
  den.aspects.opencode.homeManager =
    { pkgs, config, ... }:
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;

        settings = {
          autoupdate = false;
          theme = "catppuccin";
          permission = {
            edit = "ask";
            bash = "ask";
            skill = "allow";
            doom_loop = "ask";
            external_directory = "ask";
            webfetch = "ask";
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
      };
    };
}
