{ inputs, ... }:
{
  imports = [ inputs.bb-launcher.homeManagerModules.default ];

  programs.bb-launcher = {
    enable = true;
    gameInstallPath = "/mnt/ssd1/PS4/CUSA03173/";
    wrapperCommand = "gamemoderun mangohud";
  };
}
