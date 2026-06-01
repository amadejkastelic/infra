# The `neovim` editor aspect (home-manager). Converted from home/editors/neovim.
{
  den.aspects.neovim.homeManager = {
    programs.neovim = {
      enable = true;

      vimAlias = true;
      viAlias = true;

      withPython3 = false;
      withRuby = false;
    };

    catppuccin.nvim.enable = true;
  };
}
