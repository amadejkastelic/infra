{
  den.aspects.desktop-services.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      powerMonitorScript = pkgs.writeShellScript "power_monitor.sh" ''
        BAT=$(echo /sys/class/power_supply/BAT*)
        BAT_STATUS="$BAT/status"
        BAT_CAP="$BAT/capacity"

        AC_PROFILE="performance"
        BAT_PROFILE="power-saver"

        [[ -z $STARTUP_WAIT ]] || sleep "$STARTUP_WAIT"

        prev=0

        while true; do
        	if [[ $(cat "$BAT_STATUS") == "Discharging" ]]; then
          	profile=$BAT_PROFILE
            for i in $(hyprctl instances -j | jaq ".[].instance" -r); do
              hyprctl -i "$i" --batch 'keyword decoration:blur:enabled false; keyword animations:enabled false'
            done
        	else
        		profile=$AC_PROFILE
            for i in $(hyprctl instances -j | jaq ".[].instance" -r); do
              hyprctl -i "$i" --batch 'keyword decoration:blur:enabled true; keyword animations:enabled true'
            done
        	fi

        	if [[ $prev != "$profile" ]]; then
        		echo setting power profile to $profile
        		powerprofilesctl set $profile
        	fi

        	prev=$profile

        	inotifywait -qq "$BAT_STATUS" "$BAT_CAP"
        done
      '';

      powerMonitorDeps = with pkgs; [
        coreutils
        config.wayland.windowManager.hyprland.package
        power-profiles-daemon
        inotify-tools
        jaq
      ];
    in
    {
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit.Description = "polkit-gnome-authentication-agent-1";

        Install = {
          WantedBy = [ "graphical-session.target" ];
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # power-monitor: switches power profiles based on charging state.
      # Plugged in - performance; unplugged - power-saver.
      systemd.user.services.power-monitor = {
        Unit = {
          Description = "Power Monitor";
          After = [ "power-profiles-daemon.service" ];
        };

        Service = {
          Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath powerMonitorDeps}";
          Type = "simple";
          ExecStart = powerMonitorScript;
          Restart = "on-failure";
        };

        Install.WantedBy = [ "default.target" ];
      };

      services.udiskie.enable = true;
      systemd.user.services.udiskie.Unit.After = lib.mkForce "graphical-session.target";
    };
}
