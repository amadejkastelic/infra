{
  imports = [
    ./claude.nix
    ./herdr.nix
    ./mcp.nix
  ];

  sops.secrets = {
    z-ai-api-token = { };
    kimi-api-token = { };
    grafana-service-account-token = { };
  };
}
