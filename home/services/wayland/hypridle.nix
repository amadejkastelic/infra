{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  hyprctl =
    lib.getExe' inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
      "hyprctl";
  jq = lib.getExe pkgs.jq;

  saveWindows = pkgs.writeShellScriptBin "hyprland-save-windows" ''
    STATE_DIR="/tmp/hyprland-window-state"
    mkdir -p "$STATE_DIR"

    STATE_FILE="$STATE_DIR/floating-windows.json"
    MONITOR_FILE="$STATE_DIR/monitors.json"

    # Get all floating windows and monitor names
    ${hyprctl} clients -j | ${jq} -r '[.[] | select(.floating == true and .mapped == true) | {
      pid: .pid,
      monitor_id: .monitor,
      monitor_name: (.monitor | tostring),
      at: .at,
      fullscreen: .fullscreen
    }]' > "$STATE_FILE"

    # Save monitor names for later
    ${hyprctl} monitors -j | ${jq} -r '[.[] | select(.id >= 0) | {id: .id, name: .name}]' > "$MONITOR_FILE"

    echo "Saved floating window positions to $STATE_FILE"
    echo "Saved monitors to $MONITOR_FILE"
    ${jq} '.' "$STATE_FILE"
  '';

  restoreWindows = pkgs.writeShellScriptBin "hyprland-restore-windows" ''
    STATE_DIR="/tmp/hyprland-window-state"
    STATE_FILE="$STATE_DIR/floating-windows.json"
    MONITOR_FILE="$STATE_DIR/monitors.json"

    if [ ! -f "$STATE_FILE" ]; then
      echo "No window state file found"
      exit 1
    fi

    if [ ! -f "$MONITOR_FILE" ]; then
      echo "No monitor state file found"
      exit 1
    fi

    echo "Waiting for displays to reconnect..."

    # Get monitor names from saved state
    MONITOR_NAMES=$(${jq} -r '[.[].name | select(.)] | join(" ")' "$MONITOR_FILE")
    echo "Waiting for monitors: $MONITOR_NAMES"

    # Wait for all saved monitor names to be available
    if [ -n "$MONITOR_NAMES" ]; then
      for MONITOR_NAME in $MONITOR_NAMES; do
        echo "Waiting for monitor $MONITOR_NAME..."
        for i in $(seq 1 50); do
          AVAILABLE=$(${hyprctl} monitors -j | ${jq} -e "[.[] | select(.name == \"$MONITOR_NAME\" and .id >= 0)] | length")
          if [ "$AVAILABLE" = "1" ]; then
            echo "Monitor $MONITOR_NAME is available"
            break 2
          fi
          sleep 0.5
        done
      done
    fi

    # Additional wait for display to stabilize
    echo "Waiting for displays to stabilize..."
    sleep 2

    echo "Restoring window positions from $STATE_FILE"

    # Read the saved state and restore each window
    ${jq} -c '.[]' "$STATE_FILE" | while read -r window; do
      pid=$(${jq} -r '.pid' <<< "$window")
      x=$(${jq} -r '.at[0]' <<< "$window")
      y=$(${jq} -r '.at[1]' <<< "$window")
      fullscreen=$(${jq} -r '.fullscreen' <<< "$window")

      echo "Restoring window with pid $pid to position $x,$y"

      # Move window to original position using pid selector
      ${hyprctl} dispatch movewindowpixel "exact $x $y,pid:$pid"

      # Restore fullscreen state if needed
      if [ "$fullscreen" = "1" ]; then
        echo "Restoring fullscreen for window with pid $pid"
        ${hyprctl} dispatch togglefullscreen "pid:$pid"
      fi
    done

    # Restart Quickshell
    echo "Restarting Quickshell"
    systemctl --user restart quickshell.service

    echo "Window restoration complete"
  '';
in
{
  home.packages = [
    saveWindows
    restoreWindows
  ];

  services.hypridle = {
    enable = true;

    package = inputs.hypridle.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;

    settings = {
      general = {
        lock_cmd = "pgrep hyprlock || ${lib.getExe config.programs.hyprlock.package}";
        before_sleep_cmd = "${lib.getExe saveWindows} && ${pkgs.systemd}/bin/loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on && ${lib.getExe restoreWindows}";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "${lib.getExe saveWindows} && hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on && ${lib.getExe restoreWindows}";
        }
        /*
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        */
      ];
    };
  };
}
