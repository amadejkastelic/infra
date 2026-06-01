{ inputs, ... }:
{
  den.aspects.voxtype.homeManager =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.voxtype.homeManagerModules.default ];

      programs.voxtype = {
        enable = true;
        service.enable = true;

        package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

        model.name = "large-v3-turbo";

        settings = {
          hotkey.enabled = false;

          audio = {
            device = "default";
            sample_rate = 48000;
            max_duration_secs = 60;
          };

          whisper = {
            language = "auto";
            translate = false;
          };

          output = {
            mode = "type";
            fallback_to_clipboard = true;
          };

          state_file = "auto";
        };
      };
    };
}
