{
  den.aspects.gtk.homeManager =
    {
      config,
      ...
    }:
    {
      gtk = {
        enable = true;
        gtk4.theme = config.gtk.theme;
        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      };

      xdg.configFile = {
        "gtk-4.0/assets".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk-dark.css".source =
          "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/wm/preferences" = {
            button-layout = "";
          };
        };
      };
    };
}
