{
  config,
  lib,
  ...
}:
let
  cfg = config.services.journald-loki;
in
{
  options.services.journald-loki = {
    enable = lib.mkEnableOption "Ship systemd journald logs to a Loki instance via Grafana Alloy";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      example = "http://localhost:3100/loki/api/v1/push";
      description = "Loki push endpoint URL";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";
      description = "Hostname label attached to collected logs";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy.enable = true;

    environment.etc."alloy/config.alloy".text = ''
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "read" {
        forward_to    = [loki.write.default.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels        = { hostname = "${cfg.hostname}" }
      }

      loki.write "default" {
        endpoint {
          url = "${cfg.lokiUrl}"
        }
      }
    '';

    services.journald.extraConfig = lib.mkDefault "Storage=persistent";
  };
}
