# deploy-rs nodes derived from the den-produced nixosConfigurations. The darwin
# host (m3pro) is intentionally excluded and deployed locally via darwin-rebuild.
{ inputs, ... }:
{
  flake-file.inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake =
    { lib, config, ... }:
    {
      deploy.nodes = lib.mapAttrs' (
        hostname: nixosConfiguration:
        let
          inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
        in
        {
          name = hostname;
          value = {
            inherit hostname;
            fastConnection = false;
            sshUser = "amadejk";
            user = "root";
            profiles.system = {
              path = inputs.deploy-rs.lib.${system}.activate.nixos nixosConfiguration;
            };
          };
        }
      ) config.nixosConfigurations;
    };
}
