{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.glance-agent;

  mountpointsEnv = lib.concatStringsSep ", " (
    lib.mapAttrsToList (
      path: m: if m.hide then "!${path}" else path + lib.optionalString (m.name != null) ":${m.name}"
    ) cfg.mountpoints
  );
in
{
  options.services.glance-agent = {
    enable = lib.mkEnableOption "Glance agent exposing system metrics for Glance's server-stats widget";

    package = lib.mkPackageOption pkgs "glance-agent" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 27973;
      description = "Port for the agent HTTP API";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/glance-agent-token";
      description = ''
        Environment file containing `TOKEN=...` for API authentication.
        Must be readable by the glance-agent user.'';
    };

    cpuTempSensor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "k10temp_tctl";
      description = "CPU temperature sensor to report, see `agent sensors:print`. Auto-detected when null";
    };

    hideMountpointsByDefault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Hide all mountpoints unless explicitly enabled per mountpoint";
    };

    mountpoints = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hide = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Hide this mountpoint from the API response";
            };

            name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Display name for the mountpoint";
            };
          };
        }
      );
      default = { };
      example = {
        "/" = {
          name = "Root";
        };
        "/boot" = {
          hide = true;
        };
      };
      description = "Mountpoints to show or hide, keyed by mountpoint path";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the agent port in the firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.glance-agent = {
      description = "Glance agent user";
      group = "glance-agent";
      isSystemUser = true;
    };

    users.groups.glance-agent = { };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.glance-agent = {
      description = "Glance agent exposing system metrics via an HTTP API";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        PORT = toString cfg.port;
      }
      // lib.optionalAttrs (cfg.cpuTempSensor != null) {
        TEMP_SENSOR = cfg.cpuTempSensor;
      }
      // lib.optionalAttrs cfg.hideMountpointsByDefault {
        HIDE_MOUNTPOINTS_BY_DEFAULT = "true";
      }
      // lib.optionalAttrs (mountpointsEnv != "") {
        MOUNTPOINTS = mountpointsEnv;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/agent";
        EnvironmentFile = lib.mkIf (cfg.tokenFile != null) [ cfg.tokenFile ];
        User = "glance-agent";
        Group = "glance-agent";
        Restart = "on-failure";
        RestartSec = "5s";
        RuntimeDirectory = "glance-agent";
        WorkingDirectory = "/run/glance-agent";

        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
      };
    };
  };
}
