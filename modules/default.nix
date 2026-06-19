{
  flake.modules = {
    config = import ./config.nix;
    hardware = import ./hardware;
    services = import ./services;
  };

  flake.homeManagerModules = { };
}
