{
  den.aspects.tailscale-funnel.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.tailscale.funnel;
    in
    {
      options.services.tailscale.funnel = {
        enable = lib.mkEnableOption "Enable Tailscale funnel";

        host = lib.mkOption {
          type = lib.types.str;
          default = "localhost";
          description = "Host to bind Tailscale funnel to";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Port to bind Tailscale funnel to";
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.services.tailscale-funnel = {
          description = "Tailscale Funnel for ${cfg.host} on port ${toString cfg.port}";
          after = [ "tailscale-autoconnect.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5s";
            RemainAfterExit = true;
            ExecStart = "${config.services.tailscale.package}/bin/tailscale funnel --yes ${cfg.host}:${toString cfg.port}";
          };
        };
      };
    };
}
