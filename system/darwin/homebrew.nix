{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    global = {
      brewfile = true;
    };

    casks = [
      "karabiner-elements"
    ];
  };
}
