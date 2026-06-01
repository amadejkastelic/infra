{
  den.aspects.cli.homeManager =
    {
      pkgs,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        zip
        unzip
        unrar

        libnotify

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
