{ self, ... }:
{
  system.defaults = {
    dock = {
      autohide = true;
      minimize-to-application = true;
      show-recents = false;
      launchanim = false;
      orientation = "bottom";
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleKeyboardUIMode = 3;
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleIconAppearanceTheme = "ClearDark";
      NSAutomaticWindowAnimationsEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.keyboard.fnState" = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.swipescrolldirection" = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    spaces = {
      spans-displays = false;
    };

    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      StageManagerHideWidgets = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.activationScripts.keyboardLayout.text = ''
    cp -f ${./keyboard/Slovensko.keylayout} "/Library/Keyboard Layouts/Slovensko.keylayout"
    cp -f ${./keyboard/Slovensko.icns} "/Library/Keyboard Layouts/Slovensko.icns"
  '';
}
