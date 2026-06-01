# `obs` aspect (Linux/NixOS): OBS Studio with virtual camera and plugins.
# Replaces system/programs/obs.nix.
{
  den.aspects.obs.nixos =
    { pkgs, ... }:
    {
      programs.obs-studio = {
        enable = true;

        enableVirtualCamera = true;

        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-vkcapture
          obs-vaapi
          obs-pipewire-audio-capture
          droidcam-obs
        ];
      };
    };
}
