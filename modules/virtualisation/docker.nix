# `docker` aspect (Linux/NixOS): rootless Docker. Kept separate from the
# virtualisation aspect so the server can use Docker without pulling in libvirt.
# Replaces system/hardware/docker.nix.
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
