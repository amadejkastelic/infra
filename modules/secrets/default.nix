# `secrets` aspect: sops-nix wiring for both NixOS hosts and home-manager.
# Replaces system/core/sops.nix, hosts/common/secrets.nix and the sops bits of
# home/default.nix. Individual features declare their own sops.secrets.<name>;
# this aspect provides the modules, age keys and default sops files.
{ inputs, ... }:
{
  den.aspects.secrets = {
    nixos =
      { config, ... }:
      let
        isEd25519 = k: k.type == "ed25519";
        keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
      in
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];

        sops = {
          age.sshKeyPaths = map (k: k.path) keys;

          # common secrets shared by all NixOS hosts
          secrets = {
            hashed-password.sopsFile = ./common.yaml;
            tailscale-auth-key.sopsFile = ./common.yaml;
            gmail-password.sopsFile = ./common.yaml;
          };
        };
      };

    homeManager =
      { config, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];

        sops = {
          age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
          defaultSopsFile = ./home.yaml;
        };
      };
  };
}
