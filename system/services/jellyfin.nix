{
  pkgs,
  config,
  self,
  ...
}:
{
  services.jellyfin = {
    enable = true;

    plugins = with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      jellyfin-plugin-intro-skipper
      jellyfin-plugin-file-transformation
    ];

    nginx = {
      enable = true;
      hostName = "jellyfin.amadejk.com";
    };

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
}
