{
  self,
  inputs,
  ...
}:
let
  extraSpecialArgs = { inherit inputs self; };

  homeImports = {
    "amadejk@ryzen" = [
      ../.
      ./ryzen
    ];

    "amadejk@m3pro" = [
      ../.
      ./m3pro
    ];
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in
{
  _module.args = { inherit homeImports; };

  flake = {
    homeConfigurations = {
      "amadejk_ryzen" = homeManagerConfiguration {
        modules = homeImports."amadejk@ryzen";
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        inherit extraSpecialArgs;
      };

      "amadejk_m3pro" = homeManagerConfiguration {
        modules = homeImports."amadejk@m3pro";
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        inherit extraSpecialArgs;
      };
    };
  };
}
