let
  ds = "prometheus";

  mkAlert =
    {
      uid,
      title,
      expr,
      threshold,
      duration ? "5m",
      severity,
      summary,
    }:
    {
      inherit uid title;
      condition = "B";
      for = duration;
      noDataState = "NoData";
      execErrState = "Alerting";
      annotations.summary = summary;
      labels.severity = severity;
      isPaused = false;
      data = [
        {
          refId = "A";
          datasourceUid = ds;
          relativeTimeRange = {
            from = 600;
            to = 0;
          };
          model = {
            inherit expr;
            instant = true;
            refId = "A";
          };
        }
        {
          refId = "B";
          datasourceUid = "__expr__";
          relativeTimeRange = {
            from = 600;
            to = 0;
          };
          model = {
            type = "threshold";
            expression = "A";
            refId = "B";
            conditions = [
              {
                type = "query";
                operator.type = "and";
                query.params = [ "A" ];
                reducer.type = "last";
                evaluator = {
                  type = "gt";
                  params = [ threshold ];
                };
              }
            ];
          };
        }
      ];
    };

  fsFilter = ''fstype!~"tmpfs|devtmpfs|overlay|squashfs|nfs4|nfs",mountpoint!~"/run.*|/boot|/efi|/nix/store"'';
in
{
  services.grafana.provision.alerting.rules.settings = {
    apiVersion = 1;
    groups = [
      {
        orgId = 1;
        name = "infra";
        folder = "Server Alerts";
        interval = "60s";
        rules = [
          (mkAlert {
            uid = "host-down";
            title = "Host Down";
            expr = ''up{job="node"} == 0'';
            threshold = 0;
            severity = "critical";
            summary = "Host {{ $labels.instance }} is unreachable";
          })
          (mkAlert {
            uid = "exporter-down";
            title = "Exporter Down";
            expr = ''up{job!="node"} == 0'';
            threshold = 0;
            severity = "warning";
            summary = "Exporter {{ $labels.job }} on {{ $labels.instance }} is down";
          })
          (mkAlert {
            uid = "disk-space-warning";
            title = "Disk Space Warning";
            expr = "100 * (1 - node_filesystem_avail_bytes{${fsFilter}} / node_filesystem_size_bytes{${fsFilter}})";
            threshold = 85;
            severity = "warning";
            summary = "Filesystem {{ $labels.mountpoint }} on {{ $labels.instance }} is above 85% full";
          })
          (mkAlert {
            uid = "disk-space-critical";
            title = "Disk Space Critical";
            expr = "100 * (1 - node_filesystem_avail_bytes{${fsFilter}} / node_filesystem_size_bytes{${fsFilter}})";
            threshold = 95;
            severity = "critical";
            summary = "Filesystem {{ $labels.mountpoint }} on {{ $labels.instance }} is above 95% full";
          })
          (mkAlert {
            uid = "high-memory";
            title = "High Memory Usage";
            expr = "100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)";
            threshold = 90;
            severity = "warning";
            summary = "Memory usage on {{ $labels.instance }} is above 90%";
          })
          (mkAlert {
            uid = "systemd-failed";
            title = "Systemd Failed Units";
            expr = ''node_systemd_units{state="failed"}'';
            threshold = 0;
            severity = "warning";
            summary = "{{ $labels.instance }} has {{ $value }} failed systemd units";
          })
        ];
      }
    ];
  };
}
