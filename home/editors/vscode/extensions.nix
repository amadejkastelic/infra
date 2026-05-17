{
  config,
  pkgs,
  inputs,
  ...
}:
let
  mkNixpkgsUnfree =
    system:
    import inputs.nixpkgs-vscode {
      inherit system;
      config.allowUnfree = true;
    };
in
{
  programs.vscode = {
    mutableExtensionsDir = false;
    profiles.default.extensions =
      (with pkgs.vscode-marketplace; [
        # Icons
        pkief.material-product-icons
        pkief.material-icon-theme

        # Rust
        rust-lang.rust-analyzer

        # Python
        astral-sh.ty
        ms-python.python
        charliermarsh.ruff

        # TOML
        tamasfe.even-better-toml

        # Docker
        ms-azuretools.vscode-docker

        # Svelte
        svelte.svelte-vscode

        # go
        golang.go

        # AI
        sst-dev.opencode
        anthropic.claude-code
      ])
      ++ (with (mkNixpkgsUnfree pkgs.stdenv.hostPlatform.system).vscode-extensions; [
        # Nix
        jnoortheen.nix-ide
        mkhl.direnv

        # Rust
        vadimcn.vscode-lldb

        # Typst
        myriad-dreamin.tinymist

        # Zig
        ziglang.vscode-zig

        # Git Blame
        eamodio.gitlens

        # AI
        # continue.continue
      ]);
  };

  sops.templates."continue-config.json" = {
    content = builtins.toJSON {
      models = [
        {
          title = "GLM-4.7";
          provider = "openai";
          model = "GLM-4.7";
          apiKey = config.sops.placeholder.z-ai-api-token;
          apiBase = "https://api.z.ai/api/coding/paas/v4";
        }
        {
          title = "qwen2.5-coder";
          provider = "openai";
          model = "qwen2.5-coder";
          apiBase = "http://127.0.0.1:11434/v1";
        }
      ];
      tabAutocompleteModel = {
        title = "qwen2.5-coder";
        provider = "openai";
        model = "qwen2.5-coder";
        apiBase = "http://127.0.0.1:11434/v1";
        autocompleteOptions.maxTokens = 1024;
        temperature = 0.1;
      };
    };
    mode = "0400";
    path = "${config.home.homeDirectory}/.continue/config.json";
  };

  sops.secrets.z-ai-api-token = { };
}
