{ inputs, pkgs, ... }:
{
  services.hyprsunset = {
    enable = true;

    package = inputs.hyprsunset.packages.${pkgs.stdenv.hostPlatform.system}.hyprsunset;

    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:30";
          identity = true;
        }
        {
          time = "20:30";
          temperature = 3000;
        }
      ];
    };
  };
}
