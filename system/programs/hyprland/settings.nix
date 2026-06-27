{
  pkgs,
  inputs,
  ...
}:
let
  cursorName = "Bibata-Modern-Ice-Hyprcursor";
  cursorSize = 24;
in
{
  environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-svg
  ];

  programs.hyprland.settings = {
    "$mod" = "SUPER";
    env = [
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "XDG_SESSION_TYPE,wayland"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "GDK_BACKEND,wayland"
      "SDL_VIDEODRIVER,wayland"
      "QT_QPA_PLATFORM,wayland;xcb"
      "HYPRCURSOR_THEME,${cursorName}"
      "HYPRCURSOR_SIZE,${toString cursorSize}"
      "STEAM_FORCE_DESKTOPUI_SCALING,1.25"
      "GRIMBLAST_HIDE_CURSOR,0"
    ];

    exec-once = [
      "uwsm finalize"
      "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      "hyprlock"
      "noctalia-shell"
      # "hyprlux > /tmp/hyprlux.log 2>&1"
      "wl-paste --watch cliphist store"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 1;
      "col.active_border" = "rgba(88888888)";
      "col.inactive_border" = "rgba(00000088)";

      layout = "master";

      allow_tearing = true;
      resize_on_border = true;
    };

    decoration = {
      rounding = 10;
      rounding_power = 3;

      blur = {
        enabled = true;
        brightness = 1.0;
        contrast = 1.0;
        noise = 0.02;
        ignore_opacity = true;

        passes = 3;
        size = 10;
      };

      shadow = {
        enabled = true;
        offset = "0 2";
        range = 20;
        render_power = 3;
        color = "rgba(00000055)";
      };
    };

    animations = {
      enabled = true;
    };

    animation = [
      "border, 1, 2, default"
      "fade, 1, 4, default"
      "windows, 1, 3, default, popin 80%"
      "workspaces, 1, 2, default, slide"
    ];

    group = {
      groupbar = {
        font_size = 16;
        gradients = false;
      };

      "col.border_active" = "rgba(88888888)";
      "col.border_inactive" = "rgba(00000088)";
    };

    input = {
      kb_layout = "si";

      # focus change on cursor move
      follow_mouse = 1;
      force_no_accel = true;

      touchdevice = {
        enabled = false;
      };
    };

    master = {
      mfact = 0.40;
      new_status = "slave";
      orientation = "center";
    };

    misc = {
      # disable auto polling for config file changes
      disable_autoreload = true;

      force_default_wallpaper = 0;

      # disable annoying dialogs
      enable_anr_dialog = false;
      disable_watchdog_warning = true;

      # disable dragging animation
      animate_mouse_windowdragging = false;

      vrr = 0;
      render_unfocused_fps = 60;
    };

    render = {
      direct_scanout = true;
    };

    cursor = {
      inactive_timeout = 0;
      enable_hyprcursor = true;
      no_hardware_cursors = false;
    };

    ecosystem = {
      # Disable the permission system - allow screencopy for all apps
      enforce_permissions = false;
      no_update_news = true;
      no_donation_nag = true;
    };

    xwayland = {
      force_zero_scaling = true;
      use_nearest_neighbor = false;
    };

    debug = {
      disable_logs = true;
      full_cm_proto = false;
    };
  };

  programs.hyprland.extraConfig = ''
    plugin {
      hyprvibr {
        hyprvibr-app = cs2, 3.3, 2560, 1440, 120
      }
      dynamic-cursors {
        enabled = true
        mode = none
        shake {
          enabled = true
          nearest = false
          threshold = 3.0
          timeout = 500
          base = 2.0
        }
        hyprcursor {
          enabled = true
          nearest = false
        }
      }
    }
  '';
}
