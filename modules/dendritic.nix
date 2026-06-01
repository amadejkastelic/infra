# The den + flake-file bridge. This is the one module that turns the
# import-tree'd ./modules into a den-powered flake.
#
# - inputs.den.flakeModules.dendritic pulls in den's batteries + the flake
#   policies that walk den.hosts -> users -> homeManager and emit
#   flake.{nixos,darwin}Configurations.
# - inputs.flake-file.flakeModules.dendritic wires the distributed-inputs
#   collector so `nix run .#write-flake` can regenerate flake.nix.
{ inputs, lib, ... }:
{
  flake-file.inputs = {
    den.url = "github:denful/den";
    flake-file.url = "github:denful/flake-file";
    import-tree.url = "github:vic/import-tree";
  };

  imports = [
    (inputs.den.flakeModules.dendritic or { })
    (inputs.flake-file.flakeModules.dendritic or { })
  ];

  # Single user `amadejk`, home-manager consumed only through the system
  # (nixos/darwin) configs. Never declaring den.homes means NO standalone
  # homeConfigurations are produced.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
