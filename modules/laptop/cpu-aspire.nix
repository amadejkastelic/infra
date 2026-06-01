{
  den.aspects.cpu-aspire.nixos =
    { lib, ... }:
    {
      powerManagement = {
        cpuFreqGovernor = lib.mkForce "powersave";
        cpufreq = {
          # Limit to 2GHz (noise)
          max = 2000000;
        };
      };

      services.undervolt = {
        enable = true;
        coreOffset = -50;
        temp = 80;
      };
    };
}
