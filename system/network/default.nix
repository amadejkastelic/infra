{
  pkgs,
  lib,
  config,
  ...
}:
{
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null;
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "yes";
      };
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # DNS resolver
    resolved.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
    lib.mkIf config.networking.networkmanager.enable
      [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
