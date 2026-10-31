{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;

    extensions = [
      "just"
      "material-icon-theme"
      "nix"
      "proto"
      "starlark"
      "toml"
      "zig"
    ];

    userSettings = {
      load_direnv = "direct";

      mutableUserSettings = false;
      mutableUserKeymaps = false;

      vim_mode = false;
      format_on_save = "on";

      autosave.after_delay.milliseconds = 1000;

      icon_theme = "Material Icon Theme";

      ui_font_size = 18;
      buffer_font_size = 18;

      terminal = {
        font_size = 16;
      };

      tabs.file_icons = true;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      agent_servers = {
        "claude-code-acp" = {
          command = lib.getExe pkgs.claude-agent-acp;
          env.CLAUDE_CODE_EXECUTABLE = lib.getExe config.programs.claude-code.package;
        };
      };

      lsp = {
        starpls = {
          binary = {
            path = lib.getExe pkgs.starpls;
            arguments = [
              "server"
              "--experimental_enable_label_completions"
            ];
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          ctrl-p = "command_palette::Toggle";
          ctrl-shift-o = "file_finder::Toggle";
        };
      }
      {
        context = "Editor && mode == full";
        bindings = {
          ctrl-shift-o = "file_finder::Toggle";
        };
      }
      {
        context = "Editor";
        bindings = {
          ctrl-d = "editor::DuplicateLineDown";
        };
      }
    ];

    extraPackages = with pkgs; [
      nixd
      nixfmt
      nil
      package-version-server
      ruff
    ];
  };

  catppuccin.zed = {
    enable = true;
    icons.enable = false;
    italics = false;
  };
}
