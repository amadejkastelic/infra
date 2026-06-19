{
  lib,
  ...
}:
{
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Primary domain for services";
    };

    dnsServerIp = lib.mkOption {
      type = lib.types.str;
      description = "LAN IP of the DNS server (Blocky host)";
    };

    lanCidr = lib.mkOption {
      type = lib.types.str;
      description = "LAN network CIDR";
    };

    tailnetCidr = lib.mkOption {
      type = lib.types.str;
      description = "Tailscale CGNAT CIDR";
    };

    subdomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Subdomains registered by service configs (without the domain suffix)";
    };
  };
}
