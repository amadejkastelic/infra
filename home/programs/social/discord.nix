{ inputs, ... }:
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;

    discord = {
      enable = true;
      vencord.enable = true;
    };

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/catppuccin/discord/main/themes/mocha.theme.css"
      ];
      enabledThemes = [
        "Catppuccin Mocha"
      ];
      frameless = true;

      plugins = {
        crashHandler = {
          enable = true;
          attemptToPreventCrashes = true;
        };
        webKeybinds.enable = true;
        webScreenShareFixes.enable = true;
        silentTyping.enable = true;
        messageLogger.enable = true;
      };
    };

    # Remove titlebar
    quickCss = ''
      .bar_c38106 {
        display: none !important;
        height: 0 !important;
        min-height: 0 !important;
        max-height: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        opacity: 0 !important;
        pointer-events: none !important;
        border: none !important;
        overflow: hidden !important;
      }

      [class^="app-"] > [class^="sidebar_"] > [class^="container_"] > div:first-child {
        display: none !important;
        height: 0 !important;
      }

      [class^="base_"] {
        top: 0 !important;
        padding-top: 0 !important;
        margin-top: 0 !important;
      }

      [class^="content_"] {
        margin-top: 0 !important;
      }

      .platform-win .layer__960e4 {
        top: -53px;
      }
    '';
  };
}
