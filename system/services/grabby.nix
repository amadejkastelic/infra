{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.grabby.nixosModules.grabby ];

  services.grabby = {
    enable = true;
    logLevel = "info";
    environmentFile = config.sops.secrets.grabby-env.path;

    servers = [
      {
        serverId = "181329349167939585";
        autoEmbedChannels = [ "1459218273307721758" ];
        embedEnabled = true;
        disabledDomains = [
          "discordapp.net"
          "tenor.com"
          "kkinstagram.com"
          "fxtwitter.com"
          "vxreddit.com"
          "tnktok.com"
        ];
      }
      # FRI VSŠ
      {
        serverId = "370216420199628800";
        autoEmbedChannels = [
          "759012897979629594" # debug
          "934069591234187304" # rant
          "555027099350728714" # tech-general
          "370223615452512256" # kek-or-cringe
          "905861714908676146" # slovenski-kek-or-cringe
          "386301540417142784" # frinances
          "435071209240264704" # politics
        ];
        embedEnabled = true;
        transformOnly = true;
        allowedDomains = [
          "tiktok.com"
          "instagram.com"
          "x.com"
          "reddit.com"
        ];
      }
    ];
  };

  sops.secrets.grabby-env = {
    owner = config.services.grabby.user;
    group = config.services.grabby.group;
  };
}
