# `qbittorrent` aspect (Linux/NixOS): the custom `services.qbittorrent.nginx`
# reverse-proxy option-module (and `media` group) plus the host enabling/settings.
# Combines modules/services/qbittorrent.nix + system/services/arr/qbittorrent.nix.
{
  den.aspects.qbittorrent.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.qbittorrent.nginx;
    in
    {
      options.services.qbittorrent.nginx = {
        enable = lib.mkEnableOption "Enable nginx reverse proxy for qbittorrent";

        hostName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Host name to expose qbittorrent webui through nginx";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = config.services.qbittorrent.webuiPort;
          description = "Port to expose qbittorrent webui through nginx";
        };

        location = lib.mkOption {
          type = lib.types.str;
          default = "qbittorrent";
          description = "Location path to expose qbittorrent webui through nginx";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          users.groups.media = { };

          services.qbittorrent.group = lib.mkDefault "media";

          services.nginx = {
            enable = true;

            virtualHosts."${cfg.hostName}" = {
              locations."/${cfg.location}/" = {
                proxyPass = "http://127.0.0.1:${toString cfg.port}/";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
            };
          };
        })

        # Host config (from system/services/arr/qbittorrent.nix).
        {
          services.qbittorrent = {
            enable = true;

            nginx.enable = true;

            webuiPort = 8088;

            extraArgs = [ "--confirm-legal-notice" ];

            user = "qbittorrent";
            group = "media";

            serverConfig = {
              Core.AutoDeleteAddedTorrentFile = "Never";

              LegalNotice.Accepted = true;

              Preferences.WebUI = {
                LocalHostAuth = false;
                AuthSubnetWhitelist = "0.0.0.0/0";
              };

              BitTorrent.Session = {
                DefaultSavePath = "${config.nas.mediaDir}/downloads";
                TempPath = "${config.nas.mediaDir}/downloads/.temp";
                TempPathEnabled = true;
                AnonymousModeEnabled = true;
                GlobalMaxSeedingMinutes = -1;
                MaxActiveTorrents = -1;
                MaxActiveDownloads = -1;
                MaxActiveUploads = -1;
              };
            };
          };

          systemd.tmpfiles.settings."qbittorrent" = {
            "${config.nas.mediaDir}/downloads".d = {
              user = "qbittorrent";
              group = "media";
              mode = "0775";
            };
            "${config.nas.mediaDir}/downloads/.temp".d = {
              user = "qbittorrent";
              group = "media";
              mode = "0775";
            };
          };
        }
      ];
    };
}
