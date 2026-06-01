# `tailscale-tls` aspect (Linux/NixOS): the custom `services.tailscale.tls`
# option-module (automatic Tailscale cert renewal + nginx integration) plus the
# host enabling that lived in system/services/nginx.nix.
{
  den.aspects.tailscale-tls.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.tailscale.tls;

      tailscale = lib.getExe config.services.tailscale.package;

      domainExpression = "$(${tailscale} cert 2>&1 | grep use | cut -d '\"' -f2)";
    in
    {
      options.services.tailscale.tls = {
        enable = lib.mkEnableOption "Automatic Tailscale certificates renewal";

        certDir = lib.mkOption {
          type = lib.types.str;
          description = "Where to put certificates";
          default = "/var/lib/tailscale-tls";
        };

        mode = lib.mkOption {
          type = lib.types.str;
          description = "File mode for certificates";
          default = "0640";
        };

        domain = lib.mkOption {
          type = lib.types.str;
          description = "Override domain. Defaults to suggested one by tailscale";
          default = domainExpression;
        };

        nginx = {
          enable = lib.mkEnableOption "Integrate with Nginx";

          virtualHosts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "A list of nginx virtual hosts to put behind SSL";
          };
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          users.users = {
            tailscale-tls = {
              group = "tailscale-tls";
              home = "/var/lib/tailscale-tls";
              isSystemUser = true;
            };

            nginx = lib.mkIf cfg.nginx.enable {
              extraGroups = [ config.users.users.tailscale-tls.group ];
            };
          };

          users.groups.tailscale-tls = { };

          systemd.services.tailscale-tls = {
            description = "Automatic Tailscale certificates";

            after = [
              "network-pre.target"
              "tailscale.service"
            ];
            wants = [
              "network-pre.target"
              "tailscale.service"
            ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig.Type = "oneshot";
            script = ''
              status="Starting"

              until [ $status = "Running" ]; do
                sleep 2
                status=$(${tailscale} status -json | ${pkgs.jq}/bin/jq -r .BackendState)
              done

              mkdir -p "${cfg.certDir}"

              DOMAIN=${cfg.domain}
              CERT_FILE="${cfg.certDir}/cert.crt"
              KEY_FILE="${cfg.certDir}/key.key"

              # saved cert and key files don't seem to get updated when expired so removing files
              rm -f "$CERT_FILE"
              rm -f "$KEY_FILE"

              ${tailscale} cert \
                --cert-file "$CERT_FILE" \
                --key-file "$KEY_FILE" \
                "$DOMAIN"

              chown -R tailscale-tls:tailscale-tls "${cfg.certDir}"

              chmod ${cfg.mode} "${cfg.certDir}/cert.crt" "${cfg.certDir}/key.key"
            '';
          };

          systemd.timers.tailscale-tls = {
            description = "Automatic Tailscale certificates renewal";

            after = [
              "network-pre.target"
              "tailscale.service"
            ];
            wants = [
              "network-pre.target"
              "tailscale.service"
            ];
            wantedBy = [ "multi-user.target" ];

            timerConfig = {
              OnCalendar = "weekly";
              Persistent = "true";
              Unit = "tailscale-tls.service";
            };
          };

          services.nginx.virtualHosts = lib.genAttrs cfg.nginx.virtualHosts (vhost: {
            forceSSL = true;
            sslCertificate = "${cfg.certDir}/cert.crt";
            sslCertificateKey = "${cfg.certDir}/key.key";
          });
        })

        # Host enabling (from system/services/nginx.nix).
        {
          services.tailscale.tls = {
            enable = true;

            nginx = {
              enable = true;
              virtualHosts = [ config.networking.hostName ];
            };
          };
        }
      ];
    };
}
