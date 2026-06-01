{ inputs, ... }:
{
  den.aspects.vicinae.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];

      services.vicinae = {
        enable = true;

        systemd = {
          enable = true;

          environment = {
            USE_LAYER_SHELL = 1;
          };
        };

        settings = {
          launcher_window.opacity = lib.mkForce 0.5;

          telemetry = {
            system_info = false;
          };

          providers = {
            "applications" = {
              preferences = {
                launchPrefix = "uwsm app -- ";
              };
            };
          };

          theme = {
            dark.icon_theme = config.stylix.icons.dark;
            light.icon_theme = config.stylix.icons.light;
          };

          font = {
            normal = {
              size = config.stylix.fonts.sizes.applications;
              family = config.stylix.fonts.serif.name;
            };
          };
        };

        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          nix
          wifi-commander
        ];
      };
    };
}
