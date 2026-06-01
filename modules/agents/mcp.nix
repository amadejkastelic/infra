# The `mcp` aspect (home-manager). MCP server definitions.
# Converted from home/terminal/agents/mcp.nix.
{ inputs, ... }:
{
  den.aspects.mcp.homeManager =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      zAiBaseUrl = "https://api.z.ai/api/mcp";
      zAiAuthorization = "Bearer {env:Z_AI_API_KEY}";
    in
    {
      home.packages = with pkgs; [
        github-mcp-server
        mcp-nixos
      ];

      programs.mcp = {
        enable = true;

        servers = {
          github = {
            command = lib.getExe pkgs.github-mcp-server;
            args = [
              "stdio"
              "--read-only"
              "--toolsets"
              "context,repos,issues,pull_requests,actions"
            ];
            env.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_TOKEN}";
          };
          nix-exec = {
            command = lib.getExe inputs.nix-exec.packages.${pkgs.stdenv.hostPlatform.system}.default;
          };
          nixos = {
            command = lib.getExe pkgs.mcp-nixos;
          };
          nushell = {
            command = lib.getExe pkgs.nushell;
            args = [ "--mcp" ];
          };
          web-search-prime = {
            type = "remote";
            url = zAiBaseUrl + "/web_search_prime/mcp";
            headers.Authorization = zAiAuthorization;
          };
          web-reader = {
            type = "remote";
            url = zAiBaseUrl + "/web_reader/mcp";
            headers.Authorization = zAiAuthorization;
          };
          zread = {
            type = "remote";
            url = zAiBaseUrl + "/zread/mcp";
            headers.Authorization = zAiAuthorization;
          };
          z-ai-vision = {
            command = lib.getExe pkgs.local.z-ai-vision-mcp-server;
            env = {
              Z_AI_MODE = "ZAI";
              Z_AI_API_KEY = "{env:Z_AI_API_KEY}";
            };
          };
        };
      };
    };
}
