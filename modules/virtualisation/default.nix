# `virtualisation` aspect (Linux/NixOS): libvirtd, virt-manager, waydroid and the
# VFIO/hugepages/shared-memory option helpers. Docker lives in its own aspect
# (modules/virtualisation/docker.nix) since the server uses it without full virt.
# Replaces system/hardware/virtualisation.nix (minus docker) plus lib/vfio.nix
# and lib/virtualisation.nix (now imported relatively as _vfio.nix / _options.nix).
{
  den.aspects.virtualisation.nixos = {
    imports = [
      ./_vfio.nix
      ./_options.nix
    ];

    virtualisation = {
      waydroid.enable = false;

      vfio = {
        enable = false;
        IOMMUType = "amd";
        devices = [
          "1002:67df"
          "1002:aaf0"
        ];
        disableEFIfb = false;
      };

      libvirtd.enable = true;
    };

    programs.virt-manager.enable = true;
  };
}
