{
  den.aspects.server-services.nixos = {
    services = {
      dbus.implementation = "broker";

      psd = {
        enable = true;
        resyncTimer = "10m";
      };
    };
  };
}
