{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nixos-info-collector;

  textfileDir = "/var/lib/prometheus-node-exporter-textfiles";

  collectScript = pkgs.writeShellScript "nixos-info-collector" ''
    set -eu

    version="unknown"
    codename="unknown"
    if [ -f /etc/os-release ]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      version="''${VERSION_ID:-unknown}"
      codename="''${VERSION_CODENAME:-unknown}"
    fi

    revision="unknown"
    deployment="unknown"
    if [ -L /run/current-system ]; then
      store_path="$(readlink /run/current-system)"
      revision="$(printf '%s' "$store_path" | sed -n 's|^/nix/store/\([a-z0-9]\{1,\}\).*|\1|p')"
      [ -n "$revision" ] || revision="unknown"
      deployment="$(stat -c %y /run/current-system 2>/dev/null | cut -d'.' -f1 || echo unknown)"
    fi

    tmp="${textfileDir}/nixos-info.prom.tmp"
    out="${textfileDir}/nixos-info.prom"
    cat > "$tmp" <<EOF
    # HELP nixos_info NixOS deployment metadata per host
    # TYPE nixos_info gauge
    nixos_info{nixos_version="$version",nixos_codename="$codename",nixos_revision="$revision",nixos_deployment="$deployment"} 1
    EOF
    mv "$tmp" "$out"
  '';
in
{
  options.services.nixos-info-collector = {
    enable = lib.mkEnableOption "NixOS info textfile collector for prometheus-node-exporter";
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."node-exporter-textfiles" = {
      "${textfileDir}".d = {
        mode = "0755";
      };
    };

    systemd.services.nixos-info-collector = {
      description = "Expose NixOS deployment metadata for prometheus-node-exporter textfile collector";
      script = ''
        ${collectScript}
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.timers.nixos-info-collector = {
      wantedBy = [ "timers.target" ];
      after = [ "prometheus-node-exporter.service" ];
      timerConfig = {
        OnBootSec = "5s";
        OnUnitActiveSec = "1h";
      };
    };
  };
}
