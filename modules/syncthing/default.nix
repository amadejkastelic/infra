{
  den.aspects.syncthing.nixos = {
    networking.firewall = {
      allowedUDPPorts = [
        22000
        # syncthing discovery broadcast on ipv4 and multicast ipv6
        21027
      ];

      allowedTCPPorts = [
        42355
        22000
      ];
    };
  };
}
