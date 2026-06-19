{ config, ... }:
{
  sops.secrets."cloudflare/api_token_env" = {
    owner = "acme";
    group = "acme";
    mode = "0400";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "amadejkastelic7@gmail.com";

    certs."amadejk.com" = {
      domain = "*.amadejk.com";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare/api_token_env".path;
      group = "nginx";
    };
  };
}
