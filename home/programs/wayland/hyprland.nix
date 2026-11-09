{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;

  displays = config.workstation.displays;
  gaming = config.workstation.gaming;
  cursorName = "Bibata-Modern-Ice-Hyprcursor";
  cursorSize = 24;
  opacity = "0.93";

  bind = key: dispatcher: {
    _args = [
      key
      (mkLuaInline dispatcher)
    ];
  };
  bindFlags = key: dispatcher: flags: {
    _args = [
      key
      (mkLuaInline dispatcher)
      flags
    ];
  };
  exec = key: command: bind key "hl.dsp.exec_cmd(${builtins.toJSON command})";
  windowRule = match: effects: { inherit match; } // effects;
  layerRule =
    namespace: effects:
    {
      match = { inherit namespace; };
    }
    // effects;

  workspaces = builtins.concatLists (
    builtins.genList (
      index:
      let
        workspace = index + 1;
        key = toString (lib.mod workspace 10);
      in
      [
        (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${toString workspace} })")
        (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString workspace} })")
      ]
    ) 10
  );

  sessionVariables = {
    GDK_BACKEND = "wayland";
    GRIMBLAST_HIDE_CURSOR = "0";
    HYPRCURSOR_SIZE = toString cursorSize;
    HYPRCURSOR_THEME = cursorName;
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    STEAM_FORCE_DESKTOPUI_SCALING = builtins.toJSON (builtins.head displays).scale;
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
in
{
  home = {
    packages = [
      pkgs.grimblast
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-svg
    ];
    inherit sessionVariables;
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;
    systemd.enable = false;

    plugins = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hyprvibr
    ];

    settings = {
      monitor = map (display: {
        inherit (display) output position scale;
        mode = "${toString display.width}x${toString display.height}@${toString display.refreshRate}";
      }) displays;

      config = {
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
        animations.enabled = true;
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
          touchdevice.enabled = false;
        };
        dwindle.preserve_split = true;
        misc = {
          disable_autoreload = true;
          force_default_wallpaper = 0;
          enable_anr_dialog = false;
          disable_watchdog_warning = true;
          animate_mouse_windowdragging = false;
          vrr = 0;
          render_unfocused_fps = 60;
        };
        render.direct_scanout = true;
        cursor = {
          inactive_timeout = 0;
          enable_hyprcursor = true;
          no_hardware_cursors = false;
        };
        ecosystem = {
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

      animation = [
        {
          leaf = "border";
          enabled = true;
          speed = 2;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 4;
          bezier = "default";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 3;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 2;
          bezier = "default";
          style = "slide";
        }
      ];

      bind = [
        (bindFlags "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (bindFlags "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
        (bindFlags "SUPER + ALT + mouse:272" "hl.dsp.window.resize()" { mouse = true; })
        (bind "SUPER + Q" "hl.dsp.window.close()")
        (bind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
        (bind "SUPER + SHIFT + N" "hl.dsp.group.next()")
        (bind "SUPER + SHIFT + P" "hl.dsp.group.prev()")
        (bind "SUPER + W" ''hl.dsp.window.float({ action = "toggle" })'')
        (bind "SUPER + P" "hl.dsp.window.pseudo()")
        (exec "SUPER + M" "enabled=$(hyprctl getoption dwindle:no_gaps_when_only -j | jaq -r '.int'); if [ \"$enabled\" = 0 ]; then enabled=true; else enabled=false; fi; hyprctl eval \"hl.config({ dwindle = { no_gaps_when_only = $enabled } })\"")
        (bind "SUPER + G" ''hl.dsp.focus({ workspace = "name:Gaming" })'')
        (bind "SUPER + SHIFT + G" ''hl.dsp.window.move({ workspace = "name:Gaming" })'')
        (exec "SUPER + T" "GTK_IM_MODULE=simple ghostty")
        (exec "SUPER + L" "pgrep hyprlock || uwsm app -- hyprlock")
        (exec "SUPER + O" "uwsm app -- wl-ocr")
        (exec "SUPER + E" "vicinae vicinae://launch/core/search-emojis")
        (exec "SUPER + V" "vicinae vicinae://launch/clipboard/history")
        (exec "SUPER + N" "dolphin")
        (bind "SUPER + left" ''hl.dsp.focus({ direction = "left" })'')
        (bind "SUPER + right" ''hl.dsp.focus({ direction = "right" })'')
        (bind "SUPER + up" ''hl.dsp.focus({ direction = "up" })'')
        (bind "SUPER + down" ''hl.dsp.focus({ direction = "down" })'')
        (exec "SUPER + R" "vicinae toggle")
        (exec "SUPER + Escape" "noctalia msg panel-toggle session")
        (exec "Print" "grimblast --freeze --notify copysave area")
        (exec "SUPER + Print" "grimblast --notify --cursor copysave output")
        (bindFlags "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'' { locked = true; })
        (bindFlags "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'' { locked = true; })
        (bindFlags "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'' { locked = true; })
        (bindFlags "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'' {
          locked = true;
        })
        (bindFlags "XF86AudioMicMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'' {
          locked = true;
        })
        (bindFlags "XF86AudioRaiseVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+")''
          {
            locked = true;
            repeating = true;
          }
        )
        (bindFlags "XF86AudioLowerVolume"
          ''hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-")''
          {
            locked = true;
            repeating = true;
          }
        )
      ]
      ++ workspaces;

      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("uwsm finalize XDG_CONFIG_DIRS XDG_DATA_DIRS")
              hl.exec_cmd("hyprctl setcursor ${cursorName} ${toString cursorSize}")
            end
          '')
        ];
      };

      layer_rule = [
        (layerRule "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" {
          blur = true;
          blur_popups = true;
          ignore_alpha = 0.5;
          no_anim = true;
        })
        (layerRule "^(vicinae|gtk-layer-shell|logout_dialog)$" { blur = true; })
        (layerRule "^(gtk-layer-shell)$" {
          xray = true;
          ignore_alpha = 0.2;
        })
        (layerRule "^(vicinae)$" {
          ignore_alpha = 0.5;
          no_anim = true;
        })
      ];

      window_rule = [
        (windowRule { title = "^(Media viewer)$"; } { float = true; })
        (windowRule { title = "^Volume Control$"; } {
          float = true;
          center = true;
          size = "900 600";
          inherit opacity;
        })
        (windowRule { class = "^(nm-connection-editor)$"; } {
          float = true;
          inherit opacity;
        })
        (windowRule { initial_class = "^(org.kde.dolphin)$"; } {
          float = true;
          inherit opacity;
        })
        (windowRule { class = "^(discord|vesktop)$"; } {
          float = true;
          workspace = "8 silent";
          center = true;
          size = "1920 1080";
          inherit opacity;
        })
        (windowRule { initial_class = "^(Cider)$"; } {
          float = true;
          inherit opacity;
          workspace = "9 silent";
          center = true;
          size = "1920 1080";
        })
        (windowRule { title = "^(Picture-in-Picture)$"; } {
          float = true;
          pin = true;
        })
        (windowRule { title = "^(Firefox — Sharing Indicator)$"; } { workspace = "special silent"; })
        (windowRule { title = "^(Zen — Sharing Indicator)$"; } { workspace = "special silent"; })
        (windowRule { title = "^(.*is sharing (your screen|a window)\\.)$"; } {
          workspace = "special silent";
        })
        (windowRule { class = "^(steam)"; } { workspace = "10 silent"; })
        (windowRule { class = "gamescope"; } { workspace = "name:Gaming"; })
        (windowRule { initial_class = "cs2"; } {
          workspace = "name:Gaming";
          immediate = true;
          fullscreen = true;
          render_unfocused = true;
        })
        (windowRule { initial_class = "^(steam_app_)(.*)$"; } {
          workspace = "name:Gaming";
          immediate = true;
          fullscreen = true;
          render_unfocused = true;
        })
        (windowRule { initial_class = "^(steam_app_2964959715)$"; } {
          fullscreen = false;
          suppress_event = "maximize fullscreen activatefocus";
          float = true;
          center = true;
          size = "1920 1080";
        })
        (windowRule
          {
            initial_class = "^(steam_app_2964959715)$";
            title = "^$";
          }
          {
            opacity = "0";
            no_blur = true;
            no_focus = true;
            decorate = false;
          }
        )
        (windowRule { initial_title = "Hearthstone"; } {
          float = true;
          size = "1920 1080";
          max_size = "1920 1080";
          min_size = "1920 1080";
          center = true;
        })
        (windowRule { class = "^(mpv|.+exe|celluloid)$"; } { idle_inhibit = "focus"; })
        (windowRule {
          class = "^(firefox)$";
          title = "^(.*YouTube.*)$";
        } { idle_inhibit = "focus"; })
        (windowRule {
          class = "^(firefox)$";
          fullscreen = true;
        } { idle_inhibit = "fullscreen"; })
        (windowRule { class = "^(gcr-prompter)$"; } { dim_around = true; })
        (windowRule { class = "^(xdg-desktop-portal-gtk)$"; } {
          dim_around = true;
          float = true;
          center = true;
          size = "1920 1080";
        })
        (windowRule { class = "^(polkit-gnome-authentication-agent-1)$"; } { dim_around = true; })
        (windowRule { class = "Waydroid"; } { float = true; })
      ];
    };

    extraConfig = ''
      local function setFirefoxWindowFloating(window, action)
        hl.dispatch(
          hl.dsp.window.float({
            action = action,
            window = "address:" .. window.address,
          })
        )
      end

      local function isPendingFirefoxTitle(title)
        return title == ""
          or title == "Mozilla Firefox"
          or title == "about:blank"
          or title:match("^about:.*Mozilla Firefox$")
      end

      hl.on("window.open", function(window)
        if window == nil
          or window.class ~= "firefox"
          or window.initial_title ~= "Mozilla Firefox"
        then
          return
        end

        local firefoxWindows = hl.get_windows({ class = "firefox" })
        if #firefoxWindows <= 1 then
          return
        end

        setFirefoxWindowFloating(window, "set")

        if window.title:match("^Extension:") then
          return
        end

        if not isPendingFirefoxTitle(window.title) then
          setFirefoxWindowFloating(window, "unset")
          return
        end

        local titleSubscription
        titleSubscription = hl.on("window.title", function(updatedWindow)
          if updatedWindow == nil or updatedWindow.address ~= window.address then
            return
          end

          if isPendingFirefoxTitle(updatedWindow.title) then
            return
          end

          titleSubscription:remove()
          if not updatedWindow.title:match("^Extension:") then
            setFirefoxWindowFloating(updatedWindow, "unset")
          end
        end)
      end)

      if hl.plugin.hyprvibr then
        hl.plugin.hyprvibr.hyprvibr_app({
          class = "cs2",
          sat = 3.3,
          monitor = {
            w = ${toString gaming.width},
            h = ${toString gaming.height},
            refresh_rate = ${toString gaming.refreshRate},
          },
        })
      end
    '';
  };
}
