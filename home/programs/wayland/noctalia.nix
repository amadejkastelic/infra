{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Disable HM module
  disabledModules = [
    "programs/noctalia.nix"
  ];

  imports = [ inputs.noctalia.homeModules.default ];

  home.packages = [
    pkgs.fastfetch
    pkgs.glib
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    checkConfig = true;

    settings = {
      shell = {
        avatar_path = "/home/amadejk/.face";
        telemetry_enabled = false;

        animation = {
          enabled = true;
          speed = 1.0;
        };

        shadow = {
          direction = "down_right";
          alpha = 0.55;
        };

        privacy.mic_filter_regex = "effect_input.rnnoise|Noise Cancelling source";

        panel = {
          control_center_placement = "attached";
          session_placement = "floating";
          open_near_click_control_center = true;
        };

        session = {
          grid = true;
          grid_columns = 2;
          show_shortcuts = true;
          actions = [
            {
              action = "lock";
              command = "loginctl lock-session";
              shortcut = "1";
            }
            {
              action = "suspend";
              command = "hyprland-save-windows && systemctl suspend";
              shortcut = "2";
            }
            {
              action = "reboot";
              countdown_seconds = 10.0;
              shortcut = "3";
            }
            {
              action = "shutdown";
              countdown_seconds = 10.0;
              shortcut = "4";
              variant = "destructive";
            }
          ];
        };
      };

      theme = {
        mode = "dark";
        source = lib.mkForce "builtin";
        builtin = "Catppuccin";
      };

      location = {
        auto_locate = false;
        address = "Ljubljana, Slovenia";
      };

      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "celsius";
        effects = true;
      };

      calendar = {
        enabled = true;
        refresh_minutes = 15;
      };

      control_center = {
        calendar = {
          show_events_card = true;
          show_week_numbers = false;
        };
        shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "notification"; }
          { type = "power_profile"; }
          { type = "caffeine"; }
          { type = "session"; }
        ];
      };

      wallpaper.enabled = false;
      dock.enabled = false;
      desktop_widgets.enabled = false;
      lockscreen.enabled = false;
      nightlight.enabled = false;

      notification = {
        enable_daemon = true;
        layer = "overlay";
        offset_x = 20;
        offset_y = 8;
      };

      osd = {
        position = "bottom_center";
        position_vertical = "bottom_center";
        orientation = "horizontal";
        offset_x = 20;
        offset_y = 8;
      };

      audio = {
        enable_overdrive = false;
        enable_sounds = false;
      };

      brightness.enable_ddcutil = false;

      system.monitor = {
        enabled = true;
        cpu_poll_seconds = 3.0;
        gpu_poll_seconds = 3.0;
        memory_poll_seconds = 3.0;
        network_poll_seconds = 3.0;
        disk_poll_seconds = 30.0;
      };

      bar.main = {
        position = "top";
        thickness = 32;
        margin_ends = 4;
        margin_edge = 4;
        margin_opposite_edge = 4;
        padding = 11;
        widget_spacing = 10;
        shadow = true;
        reserve_space = true;
        capsule = false;

        start = [
          "vicinae"
          "workspaces"
        ];
        center = [ "active_window" ];
        end = [
          "privacy"
          "media"
          "cpu"
          "network"
          "tailnet"
          "tray"
          "bluetooth"
          "clock"
          "control-center"
        ];
      };

      widget = {
        vicinae = {
          type = "custom_button";
          custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          custom_image_colorize = false;
          scale = 1.25;
          tooltip = "Vicinae";
          actions.left = "exec vicinae toggle";
        };

        workspaces = {
          actions = {
            scroll_up = "none";
            scroll_down = "none";
          };
          label_source = "id";
          labels_only_when_occupied = true;
          max_label_chars = 2;
          style = "focus_hint";
          focused_output_only = false;
        };

        active_window = {
          max_length = 800;
          title_scroll = "on_hover";
          display = "icon_and_text";
          show_empty_label = false;
        };

        privacy = {
          hide_inactive = true;
          active_color = "primary";
        };

        media = {
          artist_first = true;
          min_length = 80;
          max_length = 220;
          art_size = 16;
          title_scroll = "on_hover";
          hide_when_no_media = false;
        };

        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          visualization = "gauge";
          show_value = false;
        };

        network.show_label = false;

        tailnet = {
          type = "rylos/tailnet:bar";
          show_count = false;
        };

        tray = {
          drawer = true;
          drawer_columns = 3;
          detached_panel = false;
        };

        clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%H:%M %a, %b %d}";
        };

        control-center = {
          glyph = "settings";
        };
      };

      plugins.enabled = [ "rylos/tailnet" ];
    };
  };

}
