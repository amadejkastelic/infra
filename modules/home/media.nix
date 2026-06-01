{
  den.aspects.media.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        gimp
        pavucontrol
        pulsemixer
        loupe
        audacious
        cider-2
      ];

      programs.mpv = {
        enable = true;
        defaultProfiles = [ "gpu-hq" ];
        scripts = [ pkgs.mpvScripts.mpris ];
      };

      systemd.user.services.noisetorch = {
        Unit = {
          Description = "Noisetorch Noise Cancelling";
          After = "wireplumber.service";
        };

        Service = {
          Type = "simple";
          RemainAfterExit = "yes";
          ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_FST_2018_12_11_57223-00.analog-stereo -t 95";
          ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 60s";
        };

        Install = {
          WantedBy = [
            "default.target"
          ];
        };
      };
    };
}
