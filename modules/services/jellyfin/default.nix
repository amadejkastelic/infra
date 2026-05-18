{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jellyfin;

  apiConfigurator = import ./api-configurator.nix { inherit config lib pkgs; };

  mkWaitForApiService = apiConfigurator.mkWaitForApiService;
  mkSetupWizardService = apiConfigurator.mkSetupWizardService;
  mkAuthService = apiConfigurator.mkAuthService;
  mkLibrariesService = apiConfigurator.mkLibrariesService;
  mkUserService = apiConfigurator.mkUserService;

  userPolicyOpts = {
    isAdministrator = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this user is an administrator";
    };

    isHidden = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this user is hidden from the login screen";
    };

    isDisabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this user is disabled";
    };

    enableAllChannels = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable access to all channels";
    };

    enableAllDevices = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable access to all devices";
    };

    enableAllFolders = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable access to all libraries";
    };

    enableAudioPlaybackTranscoding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable audio playback transcoding";
    };

    enableVideoPlaybackTranscoding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable video playback transcoding";
    };

    enableMediaPlayback = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable media playback";
    };

    enableCollectionManagement = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable collection management";
    };

    enableContentDeletion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable content deletion";
    };

    enableContentDownloading = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable content downloading";
    };

    enableLiveTvAccess = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Live TV access";
    };

    enableLiveTvManagement = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Live TV management";
    };

    enableMediaConversion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable media conversion";
    };

    enablePlaybackRemuxing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable playback remuxing";
    };

    enablePublicSharing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable public sharing";
    };

    enableRemoteAccess = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable remote access";
    };

    enableRemoteControlOfOtherUsers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable remote control of other users";
    };

    enableSharedDeviceControl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shared device control";
    };

    enableSubtitleManagement = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable subtitle management";
    };

    enableSyncTranscoding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sync transcoding";
    };

    forceRemoteSourceTranscoding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Force remote source transcoding";
    };

    invalidLoginAttemptCount = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Number of invalid login attempts before lockout";
    };

    loginAttemptsBeforeLockout = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Number of login attempts before lockout";
    };

    maxActiveSessions = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Maximum number of active sessions";
    };

    maxParentalRating = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Maximum parental rating";
    };

    blockedTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Blocked tags";
    };

    allowedTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Allowed tags";
    };

    blockUnratedItems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Block unrated items";
    };

    syncPlayAccess = lib.mkOption {
      type = lib.types.str;
      default = "None";
      description = "SyncPlay access level";
    };
  };

  userOpts = lib.types.submodule {
    options = {
      password = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          (lib.types.submodule {
            options._secret = lib.mkOption {
              type = lib.types.path;
              description = "Path to secret file containing password";
            };
          })
        ];
        default = null;
        description = "Password for this user (can be plain string or secret file path)";
      };

      policy = lib.mkOption {
        type = lib.types.submodule {
          options = userPolicyOpts;
        };
        default = { };
        description = "User policy settings";
      };
    };
  };

  libraryOpts = lib.types.submodule {
    options = {
      collectionType = lib.mkOption {
        type = lib.types.enum [
          "movies"
          "tvshows"
          "music"
          "homevideos"
          "books"
        ];
        description = "Collection type for the library";
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = "List of media folder paths for this library";
      };
    };
  };
in
{
  imports = [ ./nginx.nix ];

  options.services.jellyfin.apiConfig = {
    enable = lib.mkEnableOption "Enable API-based declarative configuration";

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Base URL path for Jellyfin (empty if at root)";
      example = "jellyfin";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8096;
      description = "Port for Jellyfin API";
    };

    users = lib.mkOption {
      type = lib.types.attrsOf userOpts;
      default = { };
      description = "Users to create in Jellyfin";
      example = {
        admin = {
          password = null;
          policy = {
            isAdministrator = true;
            enableAllFolders = true;
            enableMediaPlayback = true;
          };
        };
      };
    };

    libraries = lib.mkOption {
      type = lib.types.attrsOf libraryOpts;
      default = { };
      description = "Libraries to create in Jellyfin";
    };
  };

  options.services.jellyfin.plugins = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "List of Jellyfin plugins to install";
    example = lib.literalExpression "[ pkgs.jellyfin-plugin-intro-skipper ]";
  };

  config = lib.mkIf cfg.apiConfig.enable {
    services.jellyfin.apiConfig.libraries = lib.mkMerge [
      (lib.mkIf (config.services.radarr.apiConfig.enable or false) {
        Movies = {
          collectionType = "movies";
          paths = lib.map (f: f.path) config.services.radarr.apiConfig.rootFolders;
        };
      })
      (lib.mkIf (config.services.sonarr.apiConfig.enable or false) {
        "TV Shows" = {
          collectionType = "tvshows";
          paths = lib.map (f: f.path) config.services.sonarr.apiConfig.rootFolders;
        };
      })
      (lib.mkIf (config.services.sonarr-kdrama.apiConfig.enable or false) {
        "Korean Drama" = {
          collectionType = "tvshows";
          paths = lib.map (f: f.path) config.services.sonarr-kdrama.apiConfig.rootFolders;
        };
      })
      (lib.mkIf (config.services.sonarr-anime.apiConfig.enable or false) {
        Anime = {
          collectionType = "tvshows";
          paths = lib.map (f: f.path) config.services.sonarr-anime.apiConfig.rootFolders;
        };
      })
    ];

    systemd.services = {
      jellyfin-wait-api = mkWaitForApiService { };

      jellyfin-setup-wizard = mkSetupWizardService { };

      jellyfin-auth = mkAuthService { };

      jellyfin-libraries = mkLibrariesService { };

      jellyfin-users = mkUserService { };

      jellyfin-plugins = lib.mkIf (cfg.plugins != [ ]) {
        description = "Install Jellyfin plugins";
        after = [ "jellyfin-auth.service" ];
        requires = [ "jellyfin-auth.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = cfg.user;
          Group = cfg.group;
        };

        script = ''
          set -eu

          PLUGIN_DIR="${cfg.dataDir}/plugins"
          mkdir -p "$PLUGIN_DIR"

          ${lib.concatMapStringsSep "\n" (plugin: ''
            PLUGIN_NAME="$(basename ${plugin}/share/jellyfin/plugins/*)"
            PLUGIN_SRC="${plugin}/share/jellyfin/plugins/$PLUGIN_NAME"
            PLUGIN_DEST="$PLUGIN_DIR/$PLUGIN_NAME"

            if [ -L "$PLUGIN_DEST" ] || [ -e "$PLUGIN_DEST" ]; then
              rm -rf "$PLUGIN_DEST"
            fi

            cp -r "$PLUGIN_SRC" "$PLUGIN_DEST"
            chmod -R u+w "$PLUGIN_DEST"
          '') cfg.plugins}
        '';
      };
    };

    systemd.services.jellyfin.serviceConfig =
      lib.mkIf (cfg.hardwareAcceleration.enable == true && cfg.hardwareAcceleration.type == "nvenc")
        {
          DeviceAllow = [
            "char-drm rw"
            "char-nvidia rw"
            "char-nvidia-uvm rw"
          ];
          PrivateDevices = false;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_NETLINK"
            "AF_INET"
            "AF_INET6"
          ];
          Environment = [
            "LD_LIBRARY_PATH=${config.hardware.nvidia.package}/lib"
          ];
        };
  };
}
