{ config, pkgs, ... }:
let
  hasPassword = builtins.hasAttr "hashed-password" config.sops.secrets;
in
{
  users.users.amadejk = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "adbusers"
      "audio"
      "input"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "transmission"
      "video"
      "wheel"
      "gamemode"
    ];

    hashedPasswordFile = if hasPassword then config.sops.secrets.hashed-password.path else null;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN7DVOB0DJ1x6G9WetQGxzKhj2TgH8DitfTf2xof/Ep amadejkastelic7@gmail.com"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJC7gpWcNY0I6YCsfr1GPu2q+sODgQlBj4b6K/WGaMJxAAAABHNzaDo= amadejk@ryzen"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEy0xlDmuAko22lAi/eFq7uGW2LUcSBPJdON3dmOd5Oi ci@github-actions"
    ];
  };
}
