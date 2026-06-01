{
  den.aspects.dconf.nixos = {
    programs = {
      # make HM-managed GTK stuff work
      dconf.enable = true;

      seahorse.enable = false;
    };
  };
}
