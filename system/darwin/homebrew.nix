{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;

      # workaround: https://github.com/nix-darwin/nix-darwin/issues/1787
      extraFlags = [
        "--force-cleanup"
      ];
    };

    global = {
      brewfile = true;
    };

    casks = [
      # nixpkgs version crashes on launch
      "tailscale-app"
      "karabiner-elements"
      "maccy"
      "ledger-wallet"
    ];
  };
}
