# `jellyfin` aspect (Linux/NixOS): the custom Jellyfin option-module (nginx reverse
# proxy + declarative API configuration: setup wizard, users, libraries, plugins)
# plus the host enabling/settings.
#
# The option-module lives in ./_jellyfin/ (module.nix imports nginx.nix and uses
# api-configurator.nix / util.nix as sibling assets). Combines
# modules/services/jellyfin/* + system/services/jellyfin.nix.
{
  den.aspects.jellyfin.nixos =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ ./_jellyfin/module.nix ];

      services.jellyfin = {
        enable = true;

        plugins = [
          pkgs.local.jellyfin-plugin-intro-skipper
          pkgs.local.jellyfin-plugin-file-transformation
        ];

        nginx.enable = true;

        openFirewall = true;

        apiConfig = {
          enable = true;

          users = {
            admin = {
              password = {
                _secret = config.sops.secrets."jellyfin/password".path;
              };
              policy = {
                isAdministrator = true;
                enableAllFolders = true;
                enableMediaPlayback = true;
              };
            };

            amadejk = {
              password = {
                _secret = config.sops.secrets."jellyfin/password".path;
              };
              policy = {
                isAdministrator = false;
                enableAllFolders = true;
                enableMediaPlayback = true;
              };
            };
          };
        };

        transcoding = {
          enableSubtitleExtraction = true;

          hardwareEncodingCodecs = {
            hevc = true;
            av1 = true;
          };

          hardwareDecodingCodecs = {
            vp9 = true;
            vp8 = true;
            vc1 = true;
            mpeg2 = true;
            hevcRExt12bit = true;
            hevcRExt10bit = true;
            hevc10bit = true;
            hevc = true;
            h264 = true;
            av1 = true;
          };
        };
      };

      users.users."${config.services.jellyfin.user}".extraGroups = [ "media" ];

      sops.secrets."jellyfin/password" = {
        owner = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
    };
}
