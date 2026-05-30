{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./terminal
    ./theme
    inputs.nix-index-db.homeModules.nix-index
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "amadejk";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/amadejk" else "/home/amadejk";
    stateVersion = "23.11";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
  };

  targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
    linkApps.enable = false;
    copyApps.enable = true;
  };

  sops = {
    age.sshKeyPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    defaultSopsFile = ./secrets.yaml;
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
}
