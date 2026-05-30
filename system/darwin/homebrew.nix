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
      lockfiles = true;
    };

    casks = [
      "karabiner-elements"
    ];
  };
}
