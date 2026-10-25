{
  inputs,
  ...
}:
{
  systems = [ "x86_64-linux" ];

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages = {
        # instant repl with automatic flake loading
        repl = pkgs.callPackage ./repl { };

        wl-ocr = pkgs.callPackage ./wl-ocr { };

        bibata-cursors-svg = pkgs.callPackage ./bibata-cursors-svg { };

        sekiro-fps-unlock = pkgs.callPackage ./sekiro-fps-unlock { };

        z-ai-vision-mcp-server = pkgs.callPackage ./z-ai-vision-mcp-server { };

        magewell-usb-capture = pkgs.callPackage ./magewell-usb-capture { };

        ib-edavki = pkgs.callPackage ./ib-edavki { };

        jellyfin-plugin-intro-skipper = pkgs.callPackage ./jellyfin-plugin-intro-skipper { };
        jellyfin-plugin-file-transformation = pkgs.callPackage ./jellyfin-plugin-file-transformation { };

        hyprvoice = pkgs.callPackage ./hyprvoice { };

        mattpocock-skills = pkgs.callPackage ./mattpocock-skills { };

        anthropic-plugins-official = pkgs.callPackage ./anthropic-plugins-official { };
        anthropic-skills = pkgs.callPackage ./anthropic-skills { };

        nordvpn-proxy = pkgs.callPackage ./nordvpn-proxy {
          buildFirefoxXpiAddon = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon;
        };

        leshade = pkgs.callPackage ./leshade { };

        bbport = pkgs.callPackage ./bbport { };

        homeassistant-mojelektro = pkgs.callPackage ./homeassistant-mojelektro { };
      };
    };
}
