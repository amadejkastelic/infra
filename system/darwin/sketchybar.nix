{ config, pkgs, ... }:
let
  s = config.stylix.base16Scheme;
  c = builtins.mapAttrs (_: v: "0xff${v}") s;

  spaceScript = pkgs.writeShellScript "space.sh" ''
    SPACE=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.space')
    WINDOWS=$(yabai -m query --windows --space "$SPACE")
    COUNT=$(echo "$WINDOWS" | ${pkgs.jq}/bin/jq 'length')
    sketchybar --set space."$SPACE" label="$COUNT" label.drawing=on
  '';

  titleScript = pkgs.writeShellScript "title.sh" ''
    sketchybar --set title label="$(${pkgs.jq}/bin/jq -r '(.app // "") + " · " + (.title // "")' <<< "$INFO")"
  '';

  volumeScript = pkgs.writeShellScript "volume.sh" ''
    VOL=$(osascript -e "output volume of (get volume settings)")
    sketchybar --set volume label="''${VOL}%"
  '';

  batteryScript = pkgs.writeShellScript "battery.sh" ''
    PERCENT=$(pmset -g batt | ${pkgs.gnugrep}/bin/grep -Eo '[0-9]+%' | tr -d '%')
    CHARGING=$(pmset -g batt | ${pkgs.gnugrep}/bin/grep -q 'AC Power' && echo yes || echo no)
    sketchybar --set battery label="''${PERCENT}%" icon.color=$([ "$CHARGING" = "yes" ] && echo "${c.base0B}" || echo "${c.base05}")
  '';

  clockScript = pkgs.writeShellScript "clock.sh" ''
    sketchybar --set clock label="$(date +'%a %d %b %H:%M')"
  '';
in
{
  services.sketchybar = {
    enable = true;

    extraPackages = with pkgs; [
      jq
      curl
      gnugrep
    ];

    config = ''
      sketchybar --bar \
        height=32 \
        color=${c.base00} \
        border_color=${c.base01} \
        border_width=1 \
        shadow=off \
        position=top \
        sticky=on \
        padding_left=8 \
        padding_right=8 \
        margin=0 \
        y_offset=0 \
        blur_radius=0 \
        corner_radius=9

      sketchybar --default updates=when_shown \
        icon.font="${config.stylix.fonts.sansSerif.name}:Bold:15.0" \
        icon.color=${c.base05} \
        label.font="${config.stylix.fonts.sansSerif.name}:14.0" \
        label.color=${c.base05}

      sketchybar --add event windows_on_spaces

      for i in $(seq 1 9); do
        sketchybar --add space space.$i left \
          --set space.$i space=$i \
            icon=\''${i} \
            icon.highlight_color=${c.base0E} \
            label.highlight_color=${c.base0E} \
            icon.padding_left=8 \
            icon.padding_right=8 \
            label.padding_left=2 \
            label.padding_right=2 \
            background.drawing=off \
            label.drawing=off \
            script="${spaceScript}" \
          --subscribe space.$i windows_on_spaces space_windows_change
      done

      sketchybar --add item title center \
        --set title \
          icon.drawing=off \
          label.max_chars=50 \
          background.drawing=off \
          script="${titleScript}" \
        --subscribe title window_title_changed window_focus_changed front_app_switched

      sketchybar --add item volume right \
        --set volume \
          icon=Volume \
          icon.padding_left=8 \
          icon.padding_right=4 \
          label.padding_left=0 \
          label.padding_right=8 \
          script="${volumeScript}" \
          update_freq=5

      sketchybar --add item battery right \
        --set battery \
          icon=Battery \
          icon.padding_left=8 \
          icon.padding_right=4 \
          label.padding_left=0 \
          label.padding_right=8 \
          script="${batteryScript}" \
          update_freq=10

      sketchybar --add item clock right \
        --set clock \
          icon.drawing=off \
          label.padding_left=8 \
          label.padding_right=8 \
          update_freq=10 \
          script="${clockScript}"

      sketchybar --update
    '';
  };
}
