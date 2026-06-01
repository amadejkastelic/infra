{
  den.aspects.docker.nixos =
    { pkgs, ... }:
    {
      virtualisation.docker.rootless = {
        enable = true;
        package = pkgs.docker;
        setSocketVariable = true;
        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
      };
    };
}
