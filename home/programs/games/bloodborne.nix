{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [ inputs.bb-launcher.homeManagerModules.default ];

  programs.bb-launcher = {
    enable = true;
    gameInstallPath = "/mnt/hdd1/PS4/CUSA03173";
    wrapperCommand = "gamemoderun mangohud";
  };

  home.packages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.bbport
  ];
}
