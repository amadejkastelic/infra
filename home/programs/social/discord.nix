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
      themeLinks = [
        "https://raw.githubusercontent.com/catppuccin/discord/main/themes/mocha.theme.css"
      ];
      enabledThemes = [
        "Catppuccin Mocha"
      ];

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
  };
}
