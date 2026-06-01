{ inputs, lib, ... }:
{
  den.aspects.hyprland.nixos =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      hyprlandPkg =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs
          (old: {
            postInstall = (old.postInstall or "") + ''
              mkdir -p $out/share/hypr
              cp ${toString config.stylix.image} $out/share/hypr/wall0.png
            '';
          });

      cursorName = "Bibata-Modern-Ice-Hyprcursor";
      cursorSize = 24;

      screenshotarea = "grimblast --freeze --notify copysave area";

      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      workspaces = builtins.concatLists (
        builtins.genList (
          x:
          let
            ws =
              let
                c = (x + 1) / 10;
              in
              toString (x + 1 - (c * 10));
          in
          [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        ) 10
      );

      runOnce = program: "pgrep ${program} || uwsm app -- ${program}";

      opacity = "0.93";

      toRegex =
        list:
        let
          elements = lib.concatStringsSep "|" list;
        in
        "^(${elements})$";

      ignorealpha = [
        "calendar"
        "notifications"
        "osd"
        "system-menu"
        "vicinae"
      ];

      layers = ignorealpha ++ [
        "bar"
        "gtk-layer-shell"
        "logout_dialog"
      ];

      noanim = [ "vicinae" ];

      monocle = "dwindle:no_gaps_when_only";
    in
    {
      imports = [
        inputs.hyprland.nixosModules.default
      ];

      environment.systemPackages = [
        inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
        pkgs.local.bibata-cursors-svg
      ];

      environment.pathsToLink = [ "/share/icons" ];

      programs.hyprland = {
        enable = true;

        package = hyprlandPkg;

        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

        withUWSM = true;

        plugins = [
          inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
          inputs.hyprvibr.packages.${pkgs.stdenv.hostPlatform.system}.hyprvibr
        ];

        settings = {
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
            "$mod ALT, mouse:272, resizewindow"
          ];

          bind = [
            # "$mod SHIFT, E, exec, pkill Hyprland"
            "$mod, Q, killactive,"
            "$mod, F, fullscreen,"
            # "$mod, G, togglegroup,"
            "$mod SHIFT, N, changegroupactive, f"
            "$mod SHIFT, P, changegroupactive, b"
            # "$mod, R, togglesplit,"
            "$mod, W, togglefloating,"
            "$mod, P, pseudo,"
            "$mod ALT, ,resizeactive,"

            # toggle "monocle" (no_gaps_when_only)
            "$mod, M, exec, hyprctl keyword ${monocle} $(($(hyprctl getoption ${monocle} -j | jaq -r '.int') ^ 1))"

            "$mod, G, workspace, name:Gaming"
            "$mod SHIFT, G, movetoworkspace, name:Gaming"

            "$mod, T, exec, GTK_IM_MODULE=simple ghostty"
            "$mod, L, exec, ${runOnce "hyprlock"}"
            "$mod, O, exec, uwsm app -- wl-ocr"
            "$mod, E, exec, vicinae vicinae://launch/core/search-emojis"
            "$mod, V, exec, vicinae vicinae://launch/clipboard/history"
            "$mod, N, exec, nautilus"

            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            "$mod, R, exec, vicinae toggle"

            "$mod, Escape, exec, noctalia-shell ipc call sessionMenu toggle"

            # stop animations while screenshotting
            ", Print, exec, ${screenshotarea}"
            "$mod, Print, exec, grimblast --notify --cursor copysave output"
          ]
          ++ workspaces;

          bindl = [
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioNext, exec, playerctl next"

            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ];

          bindle = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"
          ];

          layerrule = [
            "match:namespace ${toRegex layers}, blur true"
            "match:namespace ${
              toRegex [
                "bar"
                "gtk-layer-shell"
              ]
            }, xray 1"
            "match:namespace ${
              toRegex [
                "bar"
                "gtk-layer-shell"
              ]
            }, ignore_alpha 0.2"
            "match:namespace ${toRegex (ignorealpha ++ [ "music" ])}, ignore_alpha 0.5"
            "match:namespace ${toRegex noanim}, no_anim on"
          ];

          windowrule = [
            "match:title ^(Media viewer)$, float true"

            "match:class ^(pavucontrol)$, float true, opacity ${opacity}"
            "match:initial_class ^(org.pulseaudio.pavucontrol)$, float true, opacity ${opacity}"
            "match:class ^(nm-connection-editor)$, float true, opacity ${opacity}"

            "match:initial_class ^(org.gnome.Nautilus)$, float true, opacity ${opacity}"

            "match:class ^(vesktop)$, float true, workspace 8 silent, center true, size 1920 1080, opacity ${opacity}"

            "match:initial_class ^(Cider)$, float true, opacity ${opacity}, workspace 9 silent, center true, size 1920 1080"

            "match:title ^(Picture-in-Picture)$, float true, pin true"

            "match:title ^(Firefox — Sharing Indicator)$, workspace special silent"
            "match:title ^(Zen — Sharing Indicator)$, workspace special silent"
            "match:title ^(.*is sharing (your screen|a window)\\.)$, workspace special silent"

            "match:class ^(steam), workspace 10 silent"

            "match:class gamescope, workspace name:Gaming"
            "match:initial_class cs2, workspace name:Gaming, immediate true, fullscreen true, render_unfocused true"
            "match:initial_class ^(steam_app_)(.*)$, workspace name:Gaming, immediate true, fullscreen true, render_unfocused true"
            "match:initial_title Hearthstone, float true, size 1920 1080, max_size 1920 1080, min_size 1920 1080, center true"

            "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
            "match:class ^(firefox)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
            "match:class ^(firefox)$, match:fullscreen true, idle_inhibit fullscreen"

            "match:class ^(gcr-prompter)$, dim_around true"
            "match:class ^(xdg-desktop-portal-gtk)$, dim_around true, float true, center true, size 1920 1080"
            "match:class ^(polkit-gnome-authentication-agent-1)$, dim_around true"

            "match:class Waydroid, float true"
          ];

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

            follow_mouse = 1;
            force_no_accel = true;

            touchdevice = {
              enabled = false;
            };
          };

          dwindle = {
            preserve_split = true;
          };

          misc = {
            disable_autoreload = true;

            force_default_wallpaper = 0;

            enable_anr_dialog = false;
            disable_watchdog_warning = true;

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

        extraConfig = ''
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
      };

      services.seatd.enable = true;

      # tell Electron/Chromium to run on Wayland
      environment.variables.NIXOS_OZONE_WL = "1";
    };
}
