let
  port = 3100;
in
{
  services.loki = {
    enable = true;
    dataDir = "/var/lib/loki";

    configuration = {
      auth_enabled = false;

      server.http_listen_port = port;
      server.grpc_listen_port = 9096;

      common.path_prefix = "/var/lib/loki";
      common.replication_factor = 1;
      common.ring.kvstore.store = "inmemory";

      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index.prefix = "index_";
          index.period = "24h";
        }
      ];

      storage_config.tsdb_shipper.active_index_directory = "/var/lib/loki/tsdb-index";
      storage_config.tsdb_shipper.cache_location = "/var/lib/loki/tsdb-cache";
      storage_config.filesystem.directory = "/var/lib/loki/chunks";

      limits_config.retention_period = "720h";

      compactor.working_directory = "/var/lib/loki/compactor";
      compactor.retention_enabled = true;
      compactor.delete_request_store = "filesystem";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      uid = "loki";
      url = "http://localhost:${toString port}";
      isDefault = false;
    }
  ];

  services.journald-loki = {
    enable = true;
    lokiUrl = "http://localhost:${toString port}/loki/api/v1/push";
  };
}
