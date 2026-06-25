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
    {
      name = "systemd-monitoring.json";
      path = patchDatasource (
        fetchGrafanaDashboard 25304 2 "sha256-TLfTwC6jhiQqNY6s5dHKAr5vMMqYzGN6MdKYFqllpNs="
      );
    }
    {
      name = "postgres-details.json";
      path = patchDatasource (
        fetchGrafanaDashboard 9628 8 "sha256-UhusNAZbyt7fJV/DhFUK4FKOmnTpG0R15YO2r+nDnMc="
      );
    }
    {
      name = "nvidia-gpu.json";
      path = patchDatasource (
        fetchGrafanaDashboard 14574 11 "sha256-0qQ+nVYZ9skOsGhpIFbTtxSkYxe7yRv6WF/56/lbgpw="
      );
    }
    {
      name = "blocky.json";
      path = patchDatasource (
        fetchGrafanaDashboard 13768 8 "sha256-gwPOcnVC7BXTlhOCRvENAXZfGdQGVCPEUrLCl4ASkVE="
      );
    }
    {
      name = "systemd-logs.json";
      path = ./systemd-logs.json;
    }
    {
      name = "rapl-energy.json";
      path = ./rapl-energy.json;
    }
    {
      name = "nixos-overview.json";
      path = ./nixos-overview.json;
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
