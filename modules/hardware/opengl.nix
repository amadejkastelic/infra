# `opengl` aspect (Linux/NixOS): graphics drivers / hardware video acceleration.
# Replaces system/hardware/opengl.nix.
{
  den.aspects.opengl.nixos =
    { pkgs, ... }:
    {
      # graphics drivers / HW accel
      hardware.graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          libva
          libvdpau
          libva-vdpau-driver
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
    };
}
