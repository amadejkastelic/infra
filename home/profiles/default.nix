{
  self,
  inputs,
  ...
}:
let
  extraSpecialArgs = { inherit inputs self; };

  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          lib = prev.lib // {
            colors = import "${self}/lib/colors" prev.lib;
          };
        })
        inputs.nix-vscode-extensions.overlays.default
        inputs.firefox-addons.overlays.default
      ]
      ++ inputs.nixpkgs.lib.optional (system == "x86_64-linux") inputs.cachyos-kernel.overlays.pinned;
    };

  homeImports = {
    "amadejk@ryzen" = [
      ../.
      ./ryzen
    ];

    "amadejk@aspire" = [
      ../.
      ./linux
      ./aspire
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
        modules = [
          inputs.stylix.homeModules.stylix
          ../../system/theme/shared.nix
        ]
        ++ homeImports."amadejk@ryzen";
        pkgs = mkPkgs "x86_64-linux";
        inherit extraSpecialArgs;
      };

      "amadejk_m3pro" = homeManagerConfiguration {
        modules = [
          inputs.stylix.homeModules.stylix
          ../../system/theme/shared.nix
        ]
        ++ homeImports."amadejk@m3pro";
        pkgs = mkPkgs "aarch64-darwin";
        inherit extraSpecialArgs;
      };
    };
  };
}
