{
  services.skhd = {
    enable = true;

    skhdConfig = ''
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east

      ctrl + alt - h : yabai -m window --resize left:-50:0
      ctrl + alt - j : yabai -m window --resize bottom:0:50
      ctrl + alt - k : yabai -m window --resize top:0:-50
      ctrl + alt - l : yabai -m window --resize right:50:0

      alt - f : yabai -m window --toggle zoom-fullscreen
      shift + alt - f : yabai -m window --toggle native-fullscreen
      shift + alt - space : yabai -m window --toggle float
      alt - r : yabai -m space --rotate 90
      alt - b : yabai -m space --balance

      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9

      shift + alt - 1 : yabai -m window --space 1
      shift + alt - 2 : yabai -m window --space 2
      shift + alt - 3 : yabai -m window --space 3
      shift + alt - 4 : yabai -m window --space 4
      shift + alt - 5 : yabai -m window --space 5
      shift + alt - 6 : yabai -m window --space 6
      shift + alt - 7 : yabai -m window --space 7
      shift + alt - 8 : yabai -m window --space 8
      shift + alt - 9 : yabai -m window --space 9

      alt - tab : yabai -m space --focus recent
      alt - 0 : yabai -m space --focus recent

      shift + alt - c : yabai -m window --close

      ctrl + alt - q : yabai -m space --destroy
      ctrl + alt - e : yabai -m space --create
    '';
  };
}
