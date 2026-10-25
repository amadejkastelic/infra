{
  flake.modules = {
    config = import ./config.nix;
    services = import ./services;
    workstation = import ./workstation.nix;
  };

  flake.homeManagerModules.workstation = import ./workstation.nix;
}
