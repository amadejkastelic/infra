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
      # nixpkgs version crashes on launch
      "tailscale-app"
      "karabiner-elements"
      "maccy"
    ];
  };
}
