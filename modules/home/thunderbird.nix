# The `thunderbird` aspect (home-manager).
# Converted from home/programs/social/thunderbird.nix.
{
  den.aspects.thunderbird.homeManager = {
    programs.thunderbird = {
      enable = true;

      profiles = {
        "default" = {
          isDefault = true;
          settings = {
            "calendar.alarms.showmissed" = false;
            "calendar.alarms.playsound" = false;
            "calendar.alarms.show" = false;
          };
        };
      };
    };
  };
}
