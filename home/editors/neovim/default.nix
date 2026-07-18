{
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./settings.nix
  ];

  programs.nvf = {
    enable = true;
    enableManpages = true;
  };
}
