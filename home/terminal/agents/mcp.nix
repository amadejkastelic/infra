{
  config,
  inputs,
  lib,
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
    mcp-grafana
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
      nixos = {
        command = lib.getExe pkgs.mcp-nixos;
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
        command = lib.getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.z-ai-vision-mcp-server;
        env = {
          Z_AI_MODE = "ZAI";
          Z_AI_API_KEY = "{env:Z_AI_API_KEY}";
        };
      };
      grafana = {
        command = lib.getExe pkgs.mcp-grafana;
        env = {
          GRAFANA_URL = "https://grafana.amadejk.com";
          GRAFANA_SERVICE_ACCOUNT_TOKEN = "{file:${config.sops.secrets.grafana-service-account-token.path}}";
        };
      };
    };
  };
}
