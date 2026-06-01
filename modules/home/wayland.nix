# The `wayland` aspect (home-manager, Linux desktop). Converted from
# home/programs/wayland/{default,hyprlock,hyprlux,noctalia}.nix,
# home/services/wayland/{hypridle,hyprpaper,hyprsunset}.nix and
# home/services/system/cliphist.nix.
{ inputs, ... }:
{
  den.aspects.wayland.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      noctaliaPluginsUrl = "https://github.com/noctalia-dev/noctalia-plugins";

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
      imports = [
        inputs.hyprlux.homeManagerModules.default
        inputs.noctalia.homeModules.default
      ];

      home.packages = [
        # screenshot
        pkgs.grim
        pkgs.slurp

        # utils
        pkgs.local.wl-ocr
        pkgs.wl-clipboard
        pkgs.wlr-randr

        pkgs.fastfetch

        saveWindows
        restoreWindows
      ];

      # make stuff work on wayland
      home.sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";
      };

      systemd.user.targets.tray.Unit.Requires = lib.mkForce [ "graphical-session.target" ];

      # cliphist
      services.cliphist = {
        enable = true;
        systemdTargets = "hyprland-session.target";
      };

      # hyprlock
      catppuccin.hyprlock.enable = true;

      programs.hyprlock = {
        enable = true;

        package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

        settings = {
          general = {
            disable_loading_bar = true;
            immediate_render = true;
            hide_cursor = false;
            no_fade_in = true;
          };

          background = [
            {
              monitor = "";
              path = toString config.stylix.image;

              blur_size = 4;
              blur_passes = 3;
              noise = 0.0117;
              contrast = 1.3000;
              brightness = 0.8000;
              vibrancy = 0.2100;
              vibrancy_darkness = 0.0;
            }
          ];
        };
      };

      # hyprlux
      programs.hyprlux = {
        enable = true;

        systemd = {
          enable = false;
          target = "graphical-session.target";
        };

        night_light = {
          enabled = true;
          latitude = 46.056946;
          longitude = 14.505751;
          temperature = 3500;
        };

        vibrance_configs = [
          {
            window_class = "steam_app_1172470";
            window_title = "Apex Legends";
            strength = 105;
          }
          {
            window_class = "cs2";
            window_title = "Counter-Strike 2";
            strength = 100;
          }
        ];
      };

      # hypridle
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
              timeout = 360;
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

      # hyprpaper
      services.hyprpaper = {
        enable = true;
        package = inputs.hyprpaper.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

      xdg.configFile."hypr/hyprpaper.conf".text = ''
        preload = ${toString config.stylix.image}

        wallpaper {
          monitor =
          path = ${toString config.stylix.image}
          fit_mode = cover
        }

        splash = false
      '';

      # hyprsunset
      services.hyprsunset = {
        enable = true;

        package = inputs.hyprsunset.packages.${pkgs.stdenv.hostPlatform.system}.hyprsunset;

        settings = {
          max-gamma = 150;

          profile = [
            {
              time = "7:30";
              identity = true;
            }
            {
              time = "19:00";
              temperature = 3000;
            }
          ];
        };
      };

      # noctalia
      programs.noctalia-shell = {
        enable = true;

        plugins = {
          sources = [
            {
              enabled = true;
              name = "Official Noctalia Plugins";
              url = noctaliaPluginsUrl;
            }
          ];
          states = {
            tailscale = {
              enabled = true;
              sourceUrl = noctaliaPluginsUrl;
            };
            privacy-indicator = {
              enabled = true;
              sourceUrl = noctaliaPluginsUrl;
            };
          };
        };

        pluginSettings = {
          tailscale = {
            compactMode = true;
            terminalCommand = "ghostty";
          };
          privacyIndicator = {
            hideInactive = true;
            removeMargins = true;
            micFilterRegex = "effect_input.rnnoise";
          };
        };

        settings = {
          settingsVersion = 44;

          bar = {
            position = "top";
            density = "default";
            showOutline = false;
            showCapsule = false;
            useSeparateOpacity = false;
            floating = true;
            marginVertical = 4;
            marginHorizontal = 4;
            outerCorners = true;
            exclusive = true;
            hideOnOverview = false;

            widgets = {
              left = [
                {
                  id = "CustomButton";
                  hideMode = "alwaysExpanded";
                  icon = "rocket";
                  leftClickExec = "vicinae toggle";
                  leftClickUpdateText = true;
                  maxTextLength = {
                    horizontal = 10;
                    vertical = 10;
                  };
                }
                {
                  id = "Workspace";
                  characterCount = 2;
                  colorizeIcons = true;
                  enableScrollWheel = false;
                  followFocusedScreen = false;
                  groupedBorderOpacity = 1;
                  hideUnoccupied = false;
                  iconScale = 0.8;
                  labelMode = "index";
                  showApplications = true;
                  showLabelsOnlyWhenOccupied = true;
                  unfocusedIconsOpacity = 1;
                }
              ];

              center = [
                {
                  id = "ActiveWindow";
                  maxWidth = 1000;
                  colorizeIcons = true;
                  scrollingMode = "hover";
                  showIcon = true;
                  useFixedWidth = false;
                  hideMode = "hidden";
                }
              ];

              right = [
                {
                  id = "plugin:privacy-indicator";
                  activeColor = "primary";
                  hideInactive = true;
                  inactiveColor = "none";
                  removeMargins = true;
                  micFilterRegex = "effect_input.rnnoise";
                }
                {
                  id = "MediaMini";
                  compactMode = true;
                  compactShowAlbumArt = true;
                  compactShowVisualizer = false;
                  panelShowAlbumArt = true;
                  panelShowVisualizer = true;
                  scrollingMode = "hover";
                  showAlbumArt = true;
                  showArtistFirst = true;
                  showProgressRing = true;
                  showVisualizer = true;
                  useFixedWidth = false;
                  visualizerType = "linear";
                }
                {
                  id = "SystemMonitor";
                  compactMode = true;
                  diskPath = "/";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskUsage = false;
                  showGpuTemp = true;
                  showLoadAverage = false;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  showSwapUsage = false;
                  useMonospaceFont = true;
                  usePrimaryColor = false;
                }
                {
                  id = "plugin:tailscale";
                }
                {
                  id = "Network";
                  displayMode = "onhover";
                }
                {
                  id = "Bluetooth";
                  displayMode = "onhover";
                }
                {
                  id = "Tray";
                  colorizeIcons = true;
                }
                {
                  id = "Clock";
                  customFont = "";
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = false;
                  usePrimaryColor = true;
                }
                {
                  id = "ControlCenter";
                  colorizeDistroLogo = false;
                  colorizeSystemIcon = "none";
                  customIconPath = "";
                  enableColorization = false;
                  icon = "settings";
                  useDistroLogo = true;
                }
              ];
            };
          };

          general = {
            avatarImage = "/home/amadejk/.face";
            dimmerOpacity = 0.2;
            showScreenCorners = false;
            forceBlackScreenCorners = false;
            scaleRatio = 1;
            radiusRatio = 1;
            iRadiusRatio = 1;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1;
            animationDisabled = false;
            compactLockScreen = false;
            lockOnSuspend = false;
            showSessionButtonsOnLockScreen = false;
            showHibernateOnLockScreen = false;
            enableShadows = true;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            language = "";
            allowPanelsOnScreenWithoutBar = true;
            showChangelogOnStartup = true;
            telemetryEnabled = false;
            enableLockScreenCountdown = true;
            lockScreenCountdownDuration = 10000;
          };

          location = {
            name = "Ljubljana, Slovenia";
            weatherEnabled = true;
            weatherShowEffects = true;
            useFahrenheit = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = false;
            showCalendarEvents = true;
            showCalendarWeather = true;
            analogClockInCalendar = false;
            firstDayOfWeek = -1;
            hideWeatherTimezone = false;
            hideWeatherCityName = false;
          };

          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };

          wallpaper.enabled = false;

          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "WallpaperSelector"; }
                { id = "NoctaliaPerformance"; }
              ];
              right = [
                { id = "Notifications"; }
                { id = "PowerProfile"; }
                { id = "KeepAwake"; }
                {
                  id = "CustomButton";
                  generalTooltipText = "Night Light";
                  icon = "moon";
                  onClicked = "hyprctl hyprsunset temperature 3000";
                  onRightClicked = "hyprctl hyprsunset identity";
                }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };

          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            gpuCriticalThreshold = 90;
            memWarningThreshold = 80;
            memCriticalThreshold = 90;
            swapWarningThreshold = 80;
            swapCriticalThreshold = 90;
            cpuPollingInterval = 3000;
            tempPollingInterval = 3000;
            gpuPollingInterval = 3000;
            enableDgpuMonitoring = false;
            memPollingInterval = 3000;
            diskPollingInterval = 30000;
            networkPollingInterval = 3000;
            loadAvgPollingInterval = 3000;
            useCustomColors = false;
            warningColor = "";
            criticalColor = "";
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          };

          dock.enabled = false;

          network = {
            wifiEnabled = true;
            bluetoothRssiPollingEnabled = false;
            bluetoothRssiPollIntervalMs = 10000;
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
          };

          sessionMenu = {
            enableCountdown = true;
            countdownDuration = 10000;
            position = "center";
            showHeader = true;
            largeButtonsStyle = false;
            largeButtonsLayout = "grid";
            showNumberLabels = true;
            powerOptions = [
              {
                action = "lock";
                command = "loginctl lock-session";
                countdownEnabled = false;
                enabled = true;
              }
              {
                action = "suspend";
                command = "hyprland-save-windows && systemctl suspend";
                countdownEnabled = false;
                enabled = true;
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = false;
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = false;
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
            ];
          };

          notifications = {
            enabled = true;
            location = "top_right";
            overlayLayer = true;
            respectExpireTimeout = false;
            lowUrgencyDuration = 3;
            normalUrgencyDuration = 8;
            criticalUrgencyDuration = 15;
            enableKeyboardLayoutToast = true;
            saveToHistory = {
              low = true;
              normal = true;
              critical = true;
            };
            sounds = {
              enabled = false;
            };
            enableMediaToast = false;
          };

          osd = {
            enabled = true;
            location = "bottom";
            autoHideMs = 2000;
            overlayLayer = true;
            enabledTypes = [
              0
              1
            ];
          };

          audio = {
            volumeStep = 5;
            volumeOverdrive = false;
            cavaFrameRate = 30;
            visualizerType = "linear";
            mprisBlacklist = [ ];
            preferredPlayer = "";
            volumeFeedback = false;
          };

          brightness = {
            brightnessStep = 5;
            enforceMinimum = true;
            enableDdcSupport = false;
          };

          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = "Monochrome";
            darkMode = true;
            schedulingMode = "off";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "tonal-spot";
            monitorForColors = "";
          };

          templates = {
            activeTemplates = [ ];
            enableUserTheming = false;
          };

          nightLight = {
            enabled = false;
            forced = false;
            autoSchedule = true;
            nightTemp = "4000";
            dayTemp = "6500";
            manualSunrise = "06:30";
            manualSunset = "18:30";
          };

          hooks = {
            enabled = false;
            wallpaperChange = "";
            darkModeChange = "";
            screenLock = "";
            screenUnlock = "";
            performanceModeEnabled = "";
            performanceModeDisabled = "";
            startup = "";
            session = "";
          };

          desktopWidgets = {
            enabled = false;
            gridSnap = false;
            monitorWidgets = [ ];
          };
        };
      };
    };
}
