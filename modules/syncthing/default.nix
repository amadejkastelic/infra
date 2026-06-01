# `syncthing` aspect (Linux/NixOS): firewall openings for syncthing
# (QUIC/discovery/transfer). Replaces system/network/syncthing.nix.
{
  den.aspects.syncthing.nixos = {
    networking.firewall = {
      allowedUDPPorts = [
        # syncthing QUIC
        22000
        # syncthing discovery broadcast on ipv4 and multicast ipv6
        21027
      ];

      allowedTCPPorts = [
        42355
        # syncthing
        22000
      ];
    };
  };
}
