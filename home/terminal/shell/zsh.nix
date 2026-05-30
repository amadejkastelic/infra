{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  fetch =
    if pkgs.stdenv.isDarwin then
      pkgs.fastfetch
    else
      inputs.nanofetch.packages.${pkgs.stdenv.hostPlatform.system}.nanofetch;
in
{
  home.packages = [
    pkgs.fzf
    fetch
  ];

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
    };
    autocd = true;
    dirHashes = {
      dl = "$HOME/Downloads";
      docs = "$HOME/Documents";
      dots = "$HOME/Projects/dotfiles";
      pics = "$HOME/Pictures";
      vids = "$HOME/Videos";
      nixpkgs = "$HOME/Projects/nixpkgs";
      projects = "$HOME/Projects";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh_history";
    };

    syntaxHighlighting.enable = true;

    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "eza -l";
      la = "eza -la";
      md = "mkdir -p";
      ssh = "TERM=xterm-color ssh";
      us = "systemctl --user";
      rs = "sudo systemctl";
    }
    // lib.optionalAttrs (config.programs.bat.enable == true) { cat = "bat"; };
    shellGlobalAliases = {
      eza = "eza --icons --git";
    };

    initContent = ''
      export CODEBERG_TOKEN="$(cat ${config.sops.secrets.codeberg-token.path} 2>/dev/null)"
      export GITHUB_TOKEN="$(cat ${config.sops.secrets.github-token.path} 2>/dev/null)"
      export Z_AI_API_KEY="$(cat ${config.sops.secrets.z-ai-api-token.path} 2>/dev/null)"

      autoload -U history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^[OA" history-beginning-search-backward-end
      bindkey "^[OB" history-beginning-search-forward-end

      # C-right / C-left for word skips
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # C-Backspace / C-Delete for word deletions
      bindkey "^[[3;5~" forward-kill-word
      bindkey "^H" backward-kill-word

      # Home/End
      bindkey "^[[OH" beginning-of-line
      bindkey "^[[OF" end-of-line

      # open commands in $EDITOR with C-e
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^e" edit-command-line

      # case insensitive tab completion
      zstyle ':completion:*' completer _complete _ignored _approximate
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle ':completion:*' verbose true

      # use cache for completions
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
      _comp_options+=(globdots)

      # Set up fzf key bindings and fuzzy completion
      source <(${lib.getExe pkgs.fzf} --zsh)

      ${lib.getExe fetch}
    '';
  };
}
