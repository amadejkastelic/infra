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
