{ self, ... }:
let
  common = [
    self.modules.config
    self.modules.services

    ./config.nix
    ./core

    ./services/podman.nix

    ./theme/catppuccin.nix

    ./network/avahi.nix
    ./network/default.nix
    ./network/nfs.nix
    ./network/tailscale.nix
  ];

  desktop = common ++ [
    self.modules.workstation

    ./core/boot.nix
    ./core/lanzaboote.nix

    ./hardware/bluetooth.nix
    ./hardware/input.nix
    ./hardware/ledger.nix
    ./hardware/opengl.nix

    ./programs

    ./services
    ./services/greetd.nix
    ./services/openrgb.nix
    ./services/pipewire.nix
    ./services/gpg.nix
    ./services/printing.nix

    ./theme/stylix.nix
  ];

  laptop = desktop ++ [ ./services/power.nix ];

  nas = common ++ [
    ./programs/msmtp.nix

    ./services/nas
  ];

  server = common ++ [
    ./programs/msmtp.nix

    ./services/acme.nix
    ./services/arr
    ./services/blocky.nix
    ./services/cloudflared.nix
    ./services/dashboard.nix
    ./services/databases
    ./services/forgejo.nix
    ./services/grabby.nix
    ./services/home-assistant
    ./services/immich
    ./services/jellyfin.nix
    ./services/metrics
    ./services/nginx.nix
    ./services/vaultwarden.nix
  ];
in
{
  inherit
    desktop
    laptop
    server
    nas
    ;
}
