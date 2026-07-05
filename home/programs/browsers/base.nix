{ pkgs, inputs }:
let
  startPagePrefs = "cad014b9ee124fd704ea0f51be2f73bfc3349588a40d189dcba79c484d35183eb373638bc54f6b19a1455c4ca2df381259d97999446bc4bfef4720783438530f26eed9e2ca3f81bcfc149bae";
  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  styles = [
    "advent-of-code"
    "arch-wiki"
    "chatgpt"
    "claude"
    "codeberg"
    "duckduckgo"
    "freedesktop"
    "github"
    "gmail"
    "google"
    "hacker-news"
    "home-manager-options-search"
    "linkedin"
    "nixos-manual"
    "nixos-search"
    "ollama"
    "perplexity"
    "pypi"
    "reddit"
    "stack-overflow"
    "startpage"
    "twitch"
    "twitter"
    "wiki.nixos.org"
    "wikipedia"
    "youtube"
  ];
  palette = inputs.nix-userstyles.inputs.nix-colors.colorSchemes."catppuccin-mocha".palette;
  userStyles =
    inputs.nix-userstyles.packages.${pkgs.stdenv.hostPlatform.system}.mkUserStyles palette
      styles;
in
{
  policies = {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = false;
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
  };

  profile = {
    settings = {
      "extensions.autoDisableScopes" = 0;

      "browser.tabs.warnOnClose" = false;
      "browser.tabs.inTitlebar" = 0;
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      # Restore previous session
      "browser.startup.page" = 3;

      # Prefer dark theme
      "layout.css.prefers-color-scheme.content-override" = 0;
      # -1.0 = auto (system DPI scaling). Explicitly set so user.js overrides
      # any stale value Firefox previously cached in prefs.js.
      "layout.css.devPixelsPerPx" = -1.0;

      "widget.use-xdg-desktop-portal.file-picker" = true;

      "dom.webnotifications.enabled" = true;
      "dom.event.clipboardevents.enabled" = true;

      "general.autoScroll" = true;
      "general.smoothScroll" = true;

      "extensions.update.enabled" = false;

      # Load profile-level stylesheets (userChrome.css / userContent.css).
      # Stock Firefox defaults this to false; Zen defaults it true.
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "layout.css.has-selector.enabled" = true;
    };

    userContent = builtins.readFile userStyles;

    extensions = {
      force = true;
      packages = with pkgs.firefox-addons; [
        auto-tab-discard
        darkreader
        ublock-origin
        sponsorblock
        bitwarden
        istilldontcareaboutcookies
        return-youtube-dislikes
        old-reddit-redirect
        ctrl-number-to-switch-tabs
        violentmonkey
        betterttv
        csgofloat
        metamask
        firefox-color
      ];
    };

    search = {
      force = true;
      default = "@sp";
      engines = {
        startpage = {
          name = "Startpage";
          urls = [
            {
              template = "https://startpage.com/sp/search?query={searchTerms}";
              params = [
                {
                  name = "prfe";
                  value = startPagePrefs;
                }
              ];
            }
          ];
          definedAliases = [ "@sp" ];
        };

        youtube = {
          name = "Youtube";
          urls = [
            {
              template = "https://www.youtube.com/results?search_query={searchTerms}";
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/commons/f/fd/YouTube_full-color_icon_%282024%29.svg";
          definedAliases = [ "@yt" ];
        };

        nixPackages = {
          name = "Nix Packages";
          urls = [
            {
              template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            }
          ];
          icon = nixIcon;
          definedAliases = [ "@np" ];
        };

        nixOptions = {
          name = "Nix Options";
          urls = [
            {
              template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
            }
          ];
          icon = nixIcon;
          definedAliases = [ "@no" ];
        };

        nixHydra = {
          name = "Nix Hydra";
          urls = [
            {
              template = "https://hydra.nixos.org/search?query={searchTerms}";
            }
          ];
          icon = nixIcon;
          definedAliases = [ "@nh" ];
        };

        homeManagerOptions = {
          name = "Nix Home Manager Options";
          urls = [
            {
              template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";
            }
          ];
          icon = nixIcon;
          definedAliases = [ "@hm" ];
        };

        stylixDocs = {
          name = "Stylix Docs";
          urls = [
            {
              template = "https://nix-community.github.io/stylix?search={searchTerms}";
            }
          ];
          icon = nixIcon;
          definedAliases = [ "@stylix" ];
        };

        githubCode = {
          name = "Github Code";
          urls = [
            {
              template = "https://github.com/search?type=code&q={searchTerms}";
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/commons/c/c2/GitHub_Invertocat_Logo.svg";
          definedAliases = [ "@gh" ];
        };

        githubRepositories = {
          name = "Github Repositories";
          urls = [
            {
              template = "https://github.com/search?type=repositories&q={searchTerms}";
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/commons/c/c2/GitHub_Invertocat_Logo.svg";
          definedAliases = [ "@ghr" ];
        };

        reddit = {
          name = "Reddit";
          urls = [
            {
              template = "https://old.reddit.com/search?q={searchTerms}";
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/en/b/bd/Reddit_Logo_Icon.svg";
          definedAliases = [ "@r" ];
        };

        perplexity = {
          name = "Perplexity";
          urls = [
            {
              template = "https://www.perplexity.ai/search?q={searchTerms}";
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/commons/b/b5/Perplexity_AI_Turquoise_on_White.png";
          definedAliases = [ "@pe" ];
        };

        cardmarket = {
          name = "Cardmarket";
          urls = [
            {
              template = "https://www.cardmarket.com/en/YuGiOh/Products/Search?category=-1&searchString={searchTerms}&category=-1&searchMode=v2";
            }
          ];
          icon = "https://www.vhv.rs/dpng/d/559-5596540_https-www-cardmarket-com-en-magicutm-campaign-card.png";
          definedAliases = [ "@cm" ];
        };

        nixpkgs-update-logs = {
          name = "ryantm";
          urls = [
            {
              template = "https://r.ryantm.com/log/{searchTerms}/";
            }
          ];
          definedAliases = [ "@nl" ];
        };
      };
    };
  };
}
