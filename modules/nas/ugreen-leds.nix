{
  den.aspects.ugreen-leds.nixos =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      user = "ugreen-leds";
      cli = lib.getExe pkgs.ugreen-leds-cli;

      monitorScript = pkgs.writeShellScript "ugreen-leds-monitor.sh" ''
        # State tracking files
        STATE_DIR="/run/ugreen-leds"
        mkdir -p "$STATE_DIR"

        # Build disk mapping dynamically from ZFS pool
        # Maps disk1, disk2, etc. to WWNs in the order they appear in zpool status
        build_disk_map() {
          local disk_num=1
          ${pkgs.zfs}/bin/zpool status storage 2>/dev/null | ${pkgs.gnugrep}/bin/grep "wwn-" | ${pkgs.gnused}/bin/sed 's/^[[:space:]]*//' | ${pkgs.coreutils}/bin/cut -d' ' -f1 | ${pkgs.coreutils}/bin/cut -d'/' -f5 | while read -r wwn_full; do
            if [[ -n "$wwn_full" && "$disk_num" -le 8 ]]; then
              # Extract just the WWN (remove wwn- prefix and -part1 suffix)
              local wwn=$(echo "$wwn_full" | ${pkgs.gnused}/bin/sed 's/^wwn-//' | ${pkgs.gnused}/bin/sed 's/-part[0-9]*$//')
              if [[ -n "$wwn" ]]; then
                echo "disk$disk_num:$wwn"
                disk_num=$((disk_num + 1))
              fi
            fi
          done
        }

        # Initialize LEDs - power solid white, network solid white
        ${cli} all -off
        ${cli} power -color 255 255 255 -on
        ${cli} netdev -color 255 255 255 -on

        # Build and load disk map
        DISK_MAP_FILE="$STATE_DIR/disk_map"
        build_disk_map > "$DISK_MAP_FILE"

        # Load disk map into array
        declare -A DISK_MAP
        while IFS=: read -r disk wwn; do
          DISK_MAP["$disk"]="$wwn"
          echo "INIT" > "$STATE_DIR/''${disk}_state"
        done < "$DISK_MAP_FILE"

        get_disk_state() {
          local wwn="$1"
          ${pkgs.zfs}/bin/zpool status storage 2>/dev/null | ${pkgs.gnugrep}/bin/grep "$wwn" | ${pkgs.gawk}/bin/awk '{print $2}'
        }

        update_disk_led() {
          local disk="$1"
          local state="$2"
          local prev_state_file="$STATE_DIR/''${disk}_state"
          local prev_state=""

          if [[ -f "$prev_state_file" ]]; then
            prev_state=$(cat "$prev_state_file")
          fi

          if [[ "$state" != "$prev_state" ]]; then
            if [[ "$state" == "ONLINE" ]]; then
              ${cli} "$disk" -color 0 255 0 -on
            else
              ${cli} "$disk" -color 255 0 0 -on
            fi
            echo "$state" > "$prev_state_file"
          fi
        }

        # Main loop
        while true; do
          for disk in "''${!DISK_MAP[@]}"; do
            wwn="''${DISK_MAP[$disk]}"
            state=$(get_disk_state "$wwn" || echo "UNKNOWN")
            [[ -z "$state" ]] && state="UNKNOWN"
            update_disk_led "$disk" "$state"
          done

          sleep 3
        done
      '';
    in
    {
      boot.kernelModules = [ "i2c-dev" ];

      services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
      '';

      hardware.i2c.enable = true;

      users.users."${user}" = {
        isSystemUser = true;
        group = config.hardware.i2c.group;
      };

      systemd.services.ugreen-leds = {
        description = "UGreen LED Controller with ZFS Health";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "zfs.target"
        ];
        serviceConfig = {
          Type = "simple";
          User = user;
          Group = config.hardware.i2c.group;
          ExecStart = monitorScript;
          Restart = "always";
          RestartSec = 5;
          RuntimeDirectory = "ugreen-leds";
        };
      };
    };
}
