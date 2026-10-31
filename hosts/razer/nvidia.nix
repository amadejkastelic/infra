{
  config,
  pkgs,
  ...
}:
let
  fenceHighTemp = 87;
  fenceLowTemp = 75;
in
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    nvidiaSettings = false;
  };

  systemd.services.nvidia-persistenced.environment = {
    LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
  };

  systemd.services.nvidia-thermal-fence = {
    description = "Pause NVENC transcodes when the GPU approaches its thermal limit";
    wantedBy = [ "multi-user.target" ];
    wants = [ "nvidia-persistenced.service" ];
    after = [ "nvidia-persistenced.service" ];
    path = [
      pkgs.coreutils
      pkgs.procps
    ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
    script = ''
      state=/run/nvidia-thermal-fence
      mkdir -p "$state"
      while true; do
        temp="$(${config.hardware.nvidia.package}/bin/nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)"
        if [ -n "$temp" ]; then
          if [ "$temp" -ge ${toString fenceHighTemp} ]; then
            if [ ! -f "$state/pids" ]; then
              echo "nvidia-thermal-fence: engaged at ''${temp}C, pausing nvenc transcodes"
            fi
            pids="$(pgrep -x ffmpeg || true)"
            if [ -n "$pids" ]; then
              kill -STOP $pids 2>/dev/null || true
              printf '%s\n' "$pids" > "$state/pids"
            else
              touch "$state/pids"
            fi
          elif [ -f "$state/pids" ] && [ "$temp" -le ${toString fenceLowTemp} ]; then
            pids="$(cat "$state/pids" 2>/dev/null || true)"
            if [ -n "$pids" ]; then
              kill -CONT $pids 2>/dev/null || true
            fi
            rm -f "$state/pids"
            echo "nvidia-thermal-fence: released at ''${temp}C, resuming nvenc transcodes"
          fi
        fi
        sleep 10
      done
    '';
  };
}
