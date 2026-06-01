{ inputs, ... }:
{
  den.aspects.social.homeManager =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nixcord.homeModules.nixcord ];

      home.packages = [ pkgs.element-desktop ];

      programs.nixcord = {
        enable = true;

        discord = {
          enable = false;
          vencord.enable = false;
        };

        vesktop = {
          enable = true;
          useSystemVencord = true;
          autoscroll.enable = true;
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
    };
}
