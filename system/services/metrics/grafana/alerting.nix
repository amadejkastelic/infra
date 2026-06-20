{ config, ... }:
let
  webhookSecret = config.sops.secrets."discord/alerts_webhook_url".path;
in
{
  sops.secrets."discord/alerts_webhook_url" = {
    owner = "grafana";
    group = "grafana";
  };

  services.grafana.provision.alerting.contactPoints.settings = {
    apiVersion = 1;
    contactPoints = [
      {
        orgId = 1;
        name = "discord";
        receivers = [
          {
            uid = "discord-1";
            type = "discord";
            settings.url = "$__file{${webhookSecret}}";
          }
        ];
      }
    ];
  };

  services.grafana.provision.alerting.policies.settings = {
    apiVersion = 1;
    policies = [
      {
        orgId = 1;
        receiver = "discord";
        group_by = [ "..." ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      }
    ];
    resetPolicies = [ 1 ];
  };
}
