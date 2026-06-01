{ inputs, ... }:
{
  den.aspects.grabby.nixos =
    { config, ... }:
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
        ];
      };

      sops.secrets.grabby-env = {
        owner = config.services.grabby.user;
        group = config.services.grabby.group;
      };
    };
}
