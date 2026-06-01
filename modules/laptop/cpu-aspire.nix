# `cpu-aspire` aspect (Linux/NixOS): aspire-specific CPU tweaks — powersave
# governor, frequency cap (noise) and undervolt. Replaces hosts/aspire/cpu.nix.
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
