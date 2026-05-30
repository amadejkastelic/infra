{
  inputs,
  self,
  homeImports,
  ...
}:
{
  networking.hostName = "m3pro";

  imports = [ ../../system/darwin ];

  home-manager = {
    users.amadejk.imports = homeImports."amadejk@m3pro";
    extraSpecialArgs = {
      inherit inputs self;
    };
  };
}
