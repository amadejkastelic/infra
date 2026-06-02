{
  system.defaults = {
    dock = {
      autohide = false;
      minimize-to-application = true;
      show-recents = false;
      launchanim = false;
      orientation = "bottom";
      tilesize = 48;
      persistent-apps = [
        { app = "/System/Applications/Mail.app"; }
        { app = "/Users/amadejk/Applications/Home Manager Apps/Visual Studio Code.app"; }
        { app = "/Users/amadejk/Applications/Home Manager Apps/Ghostty.app"; }
        { app = "/System/Applications/Music.app"; }
        { app = "/Users/amadejk/Applications/Home Manager Apps/Zen Browser (Twilight).app"; }
        { app = "/Users/amadejk/Applications/Home Manager Apps/Vesktop.app"; }
      ];
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
      NSAutomaticWindowAnimationsEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.keyboard.fnState" = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.swipescrolldirection" = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
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

  system.activationScripts.extraActivation.text = ''
    rm -f /Library/Keyboard\ Layouts/*Slovensko*
    cp -f ${./keyboard/Slovensko.keylayout} "/Library/Keyboard Layouts/Slovensko.keylayout"
    cp -f ${./keyboard/Slovensko.icns} "/Library/Keyboard Layouts/Slovensko.icns"

    rm -rf /Library/Caches/com.apple.iconservices.store
    find /private/var/folders \
      \( -name com.apple.dock.iconcache -o -name com.apple.iconservices \) \
      -exec rm -rf {} + 2>/dev/null || true
    killall iconservicesagent 2>/dev/null || true
    killall Dock 2>/dev/null || true
  '';
}
