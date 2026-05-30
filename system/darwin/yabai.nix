{ pkgs, ... }:
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      auto_balance = "on";
      split_type = "auto";
      split_ratio = "0.5";
      window_placement = "second_child";
      window_topmost = "on";

      window_gap = 8;
      top_padding = 8;
      bottom_padding = 8;
      left_padding = 8;
      right_padding = 8;

      mouse_follows_focus = "off";
      focus_follows_mouse = "off";

      window_border = "on";
      window_border_width = 2;
      window_border_radius = 3;
      window_border_blur = "off";
      active_window_border_color = "0xffcba6f7";
      normal_window_border_color = "0xff45475a";
    };

    extraConfig = ''
      yabai -m rule --add app='^System Settings$' manage=off
      yabai -m rule --add app='^System Preferences$' manage=off
      yabai -m rule --add app='^Finder$' manage=off
      yabai -m rule --add app='^Activity Monitor$' manage=off
      yabai -m rule --add app='^Karabiner-Elements$' manage=off
      yabai -m rule --add app='^Karabiner-EventViewer$' manage=off
      yabai -m rule --add title='^Preferences$' manage=off
      yabai -m rule --add title='^Settings$' manage=off
      yabai -m rule --add title='^About$' manage=off
    '';
  };
}
