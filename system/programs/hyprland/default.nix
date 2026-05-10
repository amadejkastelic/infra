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

    ./binds.nix
    ./rules.nix
    ./settings.nix
  ];

  environment.systemPackages = [
    inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-svg
  ];

  environment.pathsToLink = [ "/share/icons" ];

  programs.hyprland = {
    enable = true;

    package = hyprlandPkg;

    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    withUWSM = true;

    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      inputs.hyprvibr.packages.${pkgs.stdenv.hostPlatform.system}.hyprvibr
    ];
  };

  services.seatd.enable = true;

  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";
}
