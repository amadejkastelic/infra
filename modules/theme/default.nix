{ inputs, ... }:
{
  den.aspects.theme = {
    nixos =
      {
        pkgs,
        config,
        ...
      }:
      let
        appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        imports = [ inputs.stylix.nixosModules.stylix ];

        stylix = {
          enable = true;
          autoEnable = true;

          image = ./wallpaper.jpeg;
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

          opacity = {
            applications = 0.93;
            terminal = 0.93;
          };

          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
          };

          fonts = {
            serif = {
              package = appleFonts.sf-pro-nerd;
              name = "SFProText Nerd Font";
            };
            sansSerif = config.stylix.fonts.serif;
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };

            sizes = {
              applications = 11;
              desktop = 11;
              popups = 9;
              terminal = 12;
            };
          };
        };
      };

    darwin =
      {
        pkgs,
        config,
        ...
      }:
      {
        imports = [ inputs.stylix.darwinModules.stylix ];

        stylix = {
          enable = true;
          autoEnable = true;

          image = ./wallpaper.jpeg;
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

          opacity = {
            applications = 0.93;
            terminal = 0.93;
          };

          fonts = {
            serif = {
              package = pkgs.emptyDirectory;
              name = "SFProText";
            };
            sansSerif = config.stylix.fonts.serif;
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };

            sizes = {
              applications = 11;
              desktop = 11;
              popups = 9;
              terminal = 12;
            };
          };
        };
      };

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        imports = [ inputs.catppuccin.homeModules.catppuccin ];

        catppuccin = {
          enable = true;
          autoEnable = false;
          accent = "mauve";
          flavor = "mocha";
        };

        stylix = {
          enable = true;

          autoEnable = true;

          icons = lib.mkIf (!pkgs.stdenv.isDarwin) {
            enable = true;
            package = pkgs.papirus-icon-theme;
            dark = "Papirus-Dark";
            light = "Papirus-Light";
          };

          targets = {
            opencode.enable = false;
            neovim.enable = false;
            nixcord.enable = false;
            mangohud.enable = false;
            hyprlock.enable = false;
            zen-browser.profileNames = [ "default" ];
            hyprpaper.enable = false;
            nushell.enable = false;
            starship.enable = false;
            zed.enable = false;
          };
        };
      };
  };
}
