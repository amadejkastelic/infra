{
  hardware.openrazer = {
    enable = true;
    users = [ "amadejk" ];
  };

  systemd.services.disable-backlight = {
    description = "Disable Razer keyboard backlight";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for dev in /sys/bus/hid/drivers/razerkbd/*/matrix_brightness; do
        echo 0 > "$dev" 2>/dev/null || true
      done
    '';
  };
}
