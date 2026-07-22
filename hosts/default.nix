{
  self,
  inputs,
  homeImports,
  ...
}:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      mod = "${self}/system";

      inherit (import "${self}/system" { inherit self; })
        desktop
        laptop
        server
        nas
        ;

      specialArgs = { inherit inputs self; };
    in
    {
      ryzen = nixosSystem {
        inherit specialArgs;
        modules = desktop ++ [
          ./ryzen

          ./common/secrets.nix
          ./common/shared/nfs-mount.nix

          "${mod}/programs/hyprland"
          "${mod}/programs/gaming"

          "${mod}/hardware/virtualisation.nix"

          "${mod}/services/gnome-services.nix"

          {
            home-manager = {
              users.amadejk.imports = homeImports."amadejk@ryzen";
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };

      aspire = nixosSystem {
        inherit specialArgs;
        modules = laptop ++ [
          ./aspire

          ./common/secrets.nix
          ./common/shared/nfs-mount.nix

          "${mod}/programs/hyprland"

          "${mod}/services/gnome-services.nix"

          {
            home-manager = {
              users.amadejk.imports = homeImports."amadejk@aspire";
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };

      razer = nixosSystem {
        inherit specialArgs;
        modules = server ++ [
          ./razer

          ./common/secrets.nix
          ./common/shared/nfs-mount.nix
        ];
      };

      oblak = nixosSystem {
        inherit specialArgs;
        modules = nas ++ [
          ./oblak

          ./common/secrets.nix
        ];
      };
    };

  flake.darwinConfigurations.m3pro = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs self; };
    modules = [
      { _module.args = { inherit homeImports; }; }
      ./m3pro
    ];
  };
}
