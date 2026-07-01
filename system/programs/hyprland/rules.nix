{ lib, ... }:
let
  opacity = "0.93";
in
{
  programs.hyprland.settings = {
    layerrule =
      let
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
      in
      [
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
      # Media viewer
      "match:title ^(Media viewer)$, float true"

      # Audio/Network controls
      "match:class ^(pavucontrol)$, float true, opacity ${opacity}"
      "match:initial_class ^(org.pulseaudio.pavucontrol)$, float true, opacity ${opacity}"
      "match:class ^(nm-connection-editor)$, float true, opacity ${opacity}"

      # File manager
      "match:initial_class ^(org.gnome.Nautilus)$, float true, opacity ${opacity}"

      # Communication apps
      "match:class ^(vesktop)$, float true, workspace 8 silent, center true, size 1920 1080, opacity ${opacity}"
      "match:class ^(discord)$, float true, workspace 8 silent, center true, size 1920 1080, opacity ${opacity}"

      # Music apps
      "match:initial_class ^(Cider)$, float true, opacity ${opacity}, workspace 9 silent, center true, size 1920 1080"

      # Firefox/Zen Picture-in-Picture
      "match:title ^(Picture-in-Picture)$, float true, pin true"

      # Sharing indicators
      "match:title ^(Firefox — Sharing Indicator)$, workspace special silent"
      "match:title ^(Zen — Sharing Indicator)$, workspace special silent"
      "match:title ^(.*is sharing (your screen|a window)\\.)$, workspace special silent"

      # Steam
      "match:class ^(steam), workspace 10 silent"

      # Gaming
      "match:class gamescope, workspace name:Gaming"
      "match:initial_class cs2, workspace name:Gaming, immediate true, fullscreen true, render_unfocused true"
      "match:initial_class ^(steam_app_)(.*)$, workspace name:Gaming, immediate true, fullscreen true, render_unfocused true"
      "match:initial_title Hearthstone, float true, size 1920 1080, max_size 1920 1080, min_size 1920 1080, center true"

      # Idle inhibit
      "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
      "match:class ^(firefox)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
      "match:class ^(firefox)$, match:fullscreen true, idle_inhibit fullscreen"

      # System dialogs
      "match:class ^(gcr-prompter)$, dim_around true"
      "match:class ^(xdg-desktop-portal-gtk)$, dim_around true, float true, center true, size 1920 1080"
      "match:class ^(polkit-gnome-authentication-agent-1)$, dim_around true"

      # Waydroid
      "match:class Waydroid, float true"
    ];
  };
}
