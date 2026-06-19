{
  pkgs,
  ...
}:
let
  dsUid = "prometheus";

  fetchGrafanaDashboard =
    id: rev: hash:
    pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/${toString id}/revisions/${toString rev}/download";
      inherit hash;
    };

  patchDatasource =
    json:
    pkgs.runCommand "patched-dashboard.json" { } ''
      sed 's/''${DS_PROMETHEUS}/${dsUid}/g' ${json} > $out
    '';

  dashboardsDir = pkgs.linkFarm "grafana-dashboards" [
    {
      name = "node-exporter-full.json";
      path = patchDatasource (
        fetchGrafanaDashboard 1860 37 "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM="
      );
    }
    {
      name = "zfs-details.json";
      path = patchDatasource (
        fetchGrafanaDashboard 24987 2 "sha256-Rg1cj2eBkN+/jWpuCF37JNAFA/2Pygk3JrbRe8rNFco="
      );
    }
  ];
in
{
  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "default";
      options.path = dashboardsDir;
    }
  ];
}
