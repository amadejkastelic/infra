# The `cli` aspect (home-manager). General CLI tooling + ssh + eza.
# Converted from home/terminal/programs/cli.nix.
{
  den.aspects.cli.homeManager =
    {
      pkgs,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        # archives
        zip
        unzip
        unrar

        # misc
        libnotify

        # utils
        dust
        duf
        fd
        file
        jaq
        ripgrep
      ];

      programs = {
        eza.enable = true;
        ssh = {
          enable = true;
          enableDefaultConfig = false;

          matchBlocks = {
            # Default settings for all hosts
            "*" = {
              addKeysToAgent = "yes";
              compression = true;
              serverAliveInterval = 60;
              serverAliveCountMax = 3;
            };

            "github.com" = {
              user = "git";
              identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
            };
          };
        };
      };
    };
}
