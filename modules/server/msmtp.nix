{
  den.aspects.msmtp.nixos =
    { config, ... }:
    {
      programs.msmtp = {
        enable = true;
        setSendmail = true;

        accounts.default = {
          auth = true;
          host = "smtp.gmail.com";
          port = 587;
          tls = true;
          user = "amadejkastelic7";
          from = "${config.programs.msmtp.accounts.default.user}@gmail.com";
          passwordeval = "cat ${config.sops.secrets.gmail-password.path}";
        };
      };

      sops.secrets.gmail-password = {
        owner = config.users.users.amadejk.name;
        inherit (config.users.users.amadejk) group;
      };
    };
}
