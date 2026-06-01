{
  # https://forum.manjaro.org/t/acpi-thermal-limit-triggers-thermal-shutdown-on-sleep/154502/18
  systemd.services.thermal-fix = {
    description = "Gigabyte X570 Platform Sensor Fix";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c 'echo disabled > /sys/class/thermal/thermal_zone0/mode'";
      Restart = "on-failure";
    };
  };
}
