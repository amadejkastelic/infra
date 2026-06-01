# `ollama` aspect (Linux/NixOS): ollama (ROCm) + nextjs-ollama-llm-ui frontend.
# Replaces system/services/ollama.nix.
{
  den.aspects.ollama.nixos =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        loadModels = [ "qwen2.5-coder:7b" ];
        rocmOverrideGfx = "10.3.0";
      };

      nixpkgs.config.rocmSupport = true;

      services.nextjs-ollama-llm-ui = {
        enable = true;
        port = 3000;
        ollamaUrl = "http://127.0.0.1:${toString config.services.ollama.port}";
      };
    };
}
