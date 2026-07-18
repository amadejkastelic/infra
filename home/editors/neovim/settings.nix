{
  pkgs,
  lib,
  ...
}:
{
  programs.nvf.settings.vim = {
    viAlias = true;
    vimAlias = true;

    options = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      relativenumber = true;
      number = true;
      signcolumn = "yes";
      termguicolors = true;
      scrolloff = 8;
      wrap = false;
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
    };

    diagnostics = {
      enable = true;
      config = {
        underline = true;
        virtual_text = false;
        signs = true;
        update_in_insert = false;
      };
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy = lib.mkIf (!pkgs.stdenv.isDarwin) {
        enable = true;
      };
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };

    treesitter = {
      enable = true;
      fold = true;
      highlight.enable = true;
      indent.enable = true;
      context.enable = true;
    };

    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        keymap.preset = "super-tab";
        fuzzy.prebuilt_binaries.download = false;
        completion.documentation.auto_show = true;
        completion.menu.auto_show = true;
      };
    };

    formatter.conform-nvim = {
      enable = true;
    };

    telescope.enable = true;

    filetree.neo-tree = {
      enable = true;
      setupOpts = {
        enable_git_status = true;
        enable_diagnostics = true;
        filesystem.hijack_netrw_behavior = "open_default";
      };
    };

    statusline.lualine.enable = true;
    tabline.nvimBufferline.enable = true;

    visuals = {
      indent-blankline = {
        enable = true;
        setupOpts = {
          indent.char = "│";
          scope.enabled = true;
        };
      };
      fidget-nvim.enable = true;
      cinnamon-nvim = {
        enable = true;
        setupOpts.keymaps.basic = true;
      };
      rainbow-delimiters.enable = true;
      nvim-web-devicons.enable = true;
    };

    binds.whichKey = {
      enable = true;
      setupOpts.preset = "modern";
    };

    navigation.harpoon.enable = true;

    utility.yanky-nvim = {
      enable = true;
      setupOpts.ring.storage = "sqlite";
    };

    notes.todo-comments.enable = true;

    comments.comment-nvim = {
      enable = true;
      setupOpts.mappings.basic = true;
    };

    git = {
      gitsigns.enable = true;
      neogit.enable = true;
      git-conflict.enable = true;
    };

    languages = {
      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
        extraDiagnostics.types = [
          "statix"
          "deadnix"
        ];
      };
      rust = {
        enable = true;
        lsp.servers = [ "rust-analyzer" ];
        extensions.crates-nvim.enable = true;
      };
      python = {
        enable = true;
        lsp.servers = [
          "basedpyright"
          "ruff"
        ];
        format.type = [ "ruff" ];
      };
      go = {
        enable = true;
        lsp.servers = [ "gopls" ];
        extensions.gopher-nvim.enable = true;
      };
      zig = {
        enable = true;
        lsp.servers = [ "zls" ];
      };
      toml = {
        enable = true;
        lsp.servers = [ "taplo" ];
        format.type = [ "taplo" ];
      };
      json.enable = true;
      markdown = {
        enable = true;
        extensions.render-markdown-nvim.enable = true;
      };
    };
  };
}
