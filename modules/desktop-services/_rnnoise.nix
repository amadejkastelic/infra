# Custom `services.pipewire.rnnoise` option module (noise-cancelling source).
# Imported by the pipewire aspect; `_`-prefixed so import-tree skips it.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  cfg = config.services.pipewire.rnnoise;
  pw_rnnoise_config = {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Cancelling source";
          "media.name" = "Noise Cancelling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "librnnoise_ladspa";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = cfg.vadThreshold;
                  "VAD Grace Period (ms)" = cfg.vadGracePeriod;
                  "VAD Hangover (ms)" = cfg.vadHangover;
                };
              }
            ];
          };
          "audio.position" = [ "FL" ];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
in
{
  options.services.pipewire.rnnoise = {
    enable = mkEnableOption "rnnoise";
    vadThreshold = mkOption {
      type = types.int;
      default = 90;
      description = "Set the rnnoise VAD threshold (%)";
    };
    vadGracePeriod = mkOption {
      type = types.int;
      default = 200;
      description = "Set the rnnoise VAD grace period in milliseconds.";
    };
    vadHangover = mkOption {
      type = types.int;
      default = 400;
      description = "Set the rnnoise retroactive VAD hangover in milliseconds.";
    };
  };
  config = {
    services.pipewire = mkIf cfg.enable {
      extraLadspaPackages = [ pkgs.rnnoise-plugin ];
      extraConfig.pipewire."99-input-denoising" = pw_rnnoise_config;
    };
  };
}
