{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    accent = "mauve";
    flavor = "mocha";
  };
}
