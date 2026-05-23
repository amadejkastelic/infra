{
  self,
  inputs,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        lib = prev.lib // {
          colors = import "${self}/lib/colors" prev.lib;
        };
      })
      inputs.nix-vscode-extensions.overlays.default
      inputs.firefox-addons.overlays.default
      inputs.cachyos-kernel.overlays.pinned
      # https://github.com/NixOS/nixpkgs/pull/522705
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            jedi-language-server = python-prev.jedi-language-server.overridePythonAttrs (oldAttrs: {
              pythonRelaxDeps = [ "jedi" ];
            });
          })
        ];
      })
    ];
  };
}
