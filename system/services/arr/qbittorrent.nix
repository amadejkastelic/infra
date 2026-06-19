{ config, ... }:
{
  services.qbittorrent = {
    enable = true;

    nginx = {
      enable = true;
      hostName = "qbittorrent.amadejk.com";
    };

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
