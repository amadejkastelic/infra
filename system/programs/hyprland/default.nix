{
  inputs,
  pkgs,
  config,
  ...
}:
let
  hyprlandPkg =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs
      (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/hypr
          cp ${toString config.stylix.image} $out/share/hypr/wall0.png
        '';
      });
in
{
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-svg
  ];

  environment.pathsToLink = [ "/share/icons" ];

  programs.hyprland = {
    enable = true;

    package = hyprlandPkg;

    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM = true;

  };

  services.seatd.enable = true;
}
