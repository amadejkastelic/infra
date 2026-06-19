{
  services.grafana.provision.datasources.settings = {
    apiVersion = 1;
    prune = true;
    deleteDatasources = [
      {
        name = "Prometheus";
        orgId = 1;
      }
    ];
  };
}
