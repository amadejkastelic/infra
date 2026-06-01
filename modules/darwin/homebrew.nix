# The `homebrew` aspect: nix-darwin homebrew management.
# Replaces system/darwin/homebrew.nix.
{
  den.aspects.homebrew = {
    darwin = {
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
    };
  };
}
