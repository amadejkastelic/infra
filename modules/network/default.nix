{
  den.aspects.network.nixos =
    {
      config,
      pkgs,
      ...
    }:
    let
      nfsPorts = [
        111
        2049
        4001
        4002
      ];
      hasAuthKey = builtins.hasAttr "tailscale-auth-key" config.sops.secrets;
    in
    {
      networking.networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };

      services.openssh = {
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

      services.resolved.enable = true;

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          domain = true;
          userServices = true;
        };
        openFirewall = true;
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        authKeyFile = if hasAuthKey then config.sops.secrets.tailscale-auth-key.path else null;
      };

      boot.supportedFilesystems = [ "nfs" ];

      networking.firewall = {
        allowedTCPPorts = [ 22 ] ++ nfsPorts;
        allowedUDPPorts = nfsPorts;
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };

      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];

      environment.systemPackages = with pkgs; [ networkmanagerapplet ];
    };
}
