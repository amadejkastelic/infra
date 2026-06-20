{ config, ... }:
{
  homelab = {
    domain = "amadejk.com";
    dnsServerIp = config.homelab.hosts.razer.ip;
    lanCidr = "192.168.1.0/24";
    tailnetCidr = "100.64.0.0/10";

    hosts = {
      razer = {
        ip = "192.168.1.8";
        exporters = [
          "node"
          "postgres"
          "nvidia-gpu"
        ];
      };
      oblak = {
        ip = "192.168.1.6";
        exporters = [ "node" ];
      };
    };
  };
}
