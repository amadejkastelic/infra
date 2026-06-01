{
  config,
  lib,
  ...
}:

let
  cfg = config.services.seerr;
  nginxCfg = cfg.nginx;
in

{
  config = lib.mkIf (cfg.enable && nginxCfg.enable) {
    services.nginx = {
      enable = true;

      virtualHosts."${nginxCfg.hostName}" = {
        locations."/${nginxCfg.location}/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            # Remove /jellyseerr path to pass to the app
            rewrite ^/${nginxCfg.location}/?(.*)$ /$1 break;

            # Redirect location headers
            proxy_redirect ^ /${nginxCfg.location};
            proxy_redirect /setup /${nginxCfg.location}/setup;
            proxy_redirect /login /${nginxCfg.location}/login;

            # Sub filters to replace hardcoded paths
            proxy_set_header Accept-Encoding "";
            sub_filter_once off;
            sub_filter_types *;
            sub_filter 'href="/"' 'href="/${nginxCfg.location}"';
            sub_filter 'href="/login"' 'href="/${nginxCfg.location}/login"';
            sub_filter 'href:"/"' 'href:"/${nginxCfg.location}"';
            sub_filter '\/_next' '\/${nginxCfg.location}\/_next';
            sub_filter '/_next' '/${nginxCfg.location}/_next';
            sub_filter '/api/v1' '/${nginxCfg.location}/api/v1';
            sub_filter '/login/plex/loading' '/${nginxCfg.location}/login/plex/loading';
            sub_filter '/images/' '/${nginxCfg.location}/images/';
            sub_filter '/imageproxy/' '/${nginxCfg.location}/imageproxy/';
            sub_filter '/avatarproxy/' '/${nginxCfg.location}/avatarproxy/';
            sub_filter '/android-' '/${nginxCfg.location}/android-';
            sub_filter '/apple-' '/${nginxCfg.location}/apple-';
            sub_filter '/favicon' '/${nginxCfg.location}/favicon';
            sub_filter '/logo_' '/${nginxCfg.location}/logo_';
            sub_filter '/site.webmanifest' '/${nginxCfg.location}/site.webmanifest';
          '';
        };
      };
    };
  };
}
