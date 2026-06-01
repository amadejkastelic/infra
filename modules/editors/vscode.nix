{ inputs, ... }:
{
  den.aspects.vscode.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      mkNixpkgsUnfree =
        system:
        import inputs.nixpkgs-vscode {
          inherit system;
          config.allowUnfree = true;
        };

      vscodeUnfree = mkNixpkgsUnfree pkgs.stdenv.hostPlatform.system;

      editor = {
        "editor.fontSize" = lib.mkForce 18;
        "editor.fontWeight" = "500";
        "editor.fontLigatures" = true;
        "editor.semanticHighlighting.enabled" = true;
        "editor.guides.bracketPairs" = true;
        "editor.guides.indentation" = true;
        "editor.inlineSuggest.enabled" = true;
        "editor.smoothScrolling" = true;
        "editor.tabCompletion" = "on";
        "editor.trimAutoWhitespace" = true;
      };

      explorer = {
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
      };

      extensions = {
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "extensions.ignoreRecommendations" = true;
        "extensions.verifySignature" = false;
        "update.mode" = "none";
      };

      files = {
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "files.autoSave" = "afterDelay";
        "files.exclude" = {
          "**/__pycache__/**" = true;
        };
      };

      search = {
        "search.followSymlinks" = false;
      };

      telemetry = {
        "telemetry.telemetryLevel" = "off";
      };

      terminal = {
        "terminal.integrated.smoothScrolling" = false;
        "terminal.integrated.fontSize" = lib.mkForce 14;
        "terminal.integrated.minimumContrastRatio" = 1;
        "terminal.integrated.stickyScroll.enabled" = false;
      };

      window = {
        "window.zoomLevel" = 1;
        "window.titleBarStyle" = "native";
        "window.customTitleBarVisibility" = "never";
        "window.menuBarVisibility" = "toggle";
        "window.dialogStyle" = "native";
      };

      workbench = {
        "workbench.colorTheme" = lib.mkForce "Catppuccin Mocha";
        "workbench.iconTheme" = lib.mkForce "material-icon-theme";
        "workbench.productIconTheme" = "material-product-icons";
        "workbench.startupEditor" = "none";
        "workbench.editor.tabActionCloseVisibility" = false;
      };

      update = {
        "update.showReleaseNotes" = false;
      };

      catppuccin = {
        "catppuccin.italicComments" = false;
        "catppuccin.italicKeywords" = false;
        "catppuccin.extraBordersEnabled" = false;
        "catppuccin.workbenchMode" = "default";
        "catppuccin.bracketMode" = "rainbow";
        "catppuccin.customUIColors" = {
          "all" = {
            "statusBar.foreground" = "accent";
            "statusBar.noFolderForeground" = "accent";
          };
        };
      };

      formatter = {
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "[python]"."editor.defaultFormatter" = "charliermarsh.ruff";
      };

      nix = {
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "nixfmt";
        "nix.serverPath" = lib.getExe pkgs.nixd;
        "nix.serverSettings"."nixd"."formatting"."command" = [ "${lib.getExe pkgs.nixfmt}" ];
        "[nix]" = {
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
        };
      };

      python = {
        "python.defaultInterpreterPath" = lib.getExe pkgs.python3;
        "python.languageServer" = "Pylance";
        "python.analysis.typeCheckingMode" = "strict";
      };

      zig = {
        "zig.path" = "zig";
        "zig.zls.enabled" = "on";
        "zig.zls.path" = "zls";
      };

      continue = {
        "continue.telemetryEnabled" = false;
        "continue.enableTabAutocomplete" = true;
      };

      svelte = {
        "svelte.enable-ts-plugin" = true;
      };

      copilot = {
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };
        "chat.disableAIFeatures" = true;
      };

      claude-code = {
        "claudeCode.preferredLocation" = "panel";
        "claudeCode.useTerminal" = true;
      };
    in
    {
      imports = [ inputs.vscode-server.homeModules.default ];

      programs.vscode = {
        enable = true;

        # https://github.com/microsoft/vscode/issues/260391
        package = vscodeUnfree.vscode;

        mutableExtensionsDir = false;

        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          extensions =
            (with pkgs.vscode-marketplace; [
              pkief.material-product-icons
              pkief.material-icon-theme

              rust-lang.rust-analyzer

              astral-sh.ty
              ms-python.python
              charliermarsh.ruff

              tamasfe.even-better-toml

              ms-azuretools.vscode-docker

              golang.go

              sst-dev.opencode
              anthropic.claude-code
            ])
            ++ (with vscodeUnfree.vscode-extensions; [
              jnoortheen.nix-ide
              mkhl.direnv

              vadimcn.vscode-lldb

              myriad-dreamin.tinymist

              ziglang.vscode-zig

              eamodio.gitlens

              svelte.svelte-vscode

              # continue.continue
            ]);

          keybindings = [
            {
              key = "ctrl+shift+o";
              command = "workbench.action.quickOpen";
            }
            {
              key = "ctrl+d";
              command = "editor.action.copyLinesDownAction";
            }
            {
              key = "shift+enter";
              command = "workbench.action.terminal.sendSequence";
              args.text = "\\\r\n";
              when = "terminalFocus";
            }
          ];

          userSettings =
            { }
            // editor
            // explorer
            // extensions
            // files
            // search
            // telemetry
            // terminal
            // window
            // workbench
            // update
            // catppuccin
            // formatter
            // nix
            // python
            // zig
            // continue
            // svelte
            // copilot
            // claude-code;
        };
      };

      catppuccin.vscode.profiles.default.enable = true;

      xdg.mimeApps.defaultApplications."text/plain" = "code.desktop";

      services.vscode-server = {
        enable = true;
        enableFHS = false;
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
    };
}
