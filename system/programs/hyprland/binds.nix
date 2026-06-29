let
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
in
{
  programs.hyprland.settings = {
    # mouse movements
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    # binds
    bind =
      let
        monocle = "dwindle:no_gaps_when_only";
      in
      [
        # compositor commands
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

        # Gaming workspace
        "$mod, G, workspace, name:Gaming"
        "$mod SHIFT, G, movetoworkspace, name:Gaming"

        # utility
        # terminal
        "$mod, T, exec, GTK_IM_MODULE=simple ghostty"
        # lock screen
        "$mod, L, exec, ${runOnce "hyprlock"}"
        # select area to perform OCR on
        "$mod, O, exec, uwsm app -- wl-ocr"
        # Emoji picker
        "$mod, E, exec, vicinae vicinae://launch/core/search-emojis"
        # Clipboard manager
        "$mod, V, exec, vicinae vicinae://launch/clipboard/history"
        # File manager
        "$mod, N, exec, nautilus"

        # move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Launcher
        "$mod, R, exec, vicinae toggle"

        # Session menu
        "$mod, Escape, exec, noctalia-shell ipc call sessionMenu toggle"

        # screenshot
        # stop animations while screenshotting
        ", Print, exec, ${screenshotarea}"
        "$mod, Print, exec, grimblast --notify --cursor copysave output"
      ]
      ++ workspaces;

    bindl = [
      # media controls
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"

      # volume
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindle = [
      # volume
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"
    ];
  };
}
