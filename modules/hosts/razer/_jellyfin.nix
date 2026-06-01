{ lib, ... }:
{
  services.jellyfin = {
    hardwareAcceleration = {
      enable = true;
      type = "nvenc";
      device = "/dev/nvidia0";
    };

    transcoding = {
      enableHardwareEncoding = true;
      enableSubtitleExtraction = true;
      enableToneMapping = false;

      hardwareEncodingCodecs = {
        av1 = lib.mkForce false;
      };

      hardwareDecodingCodecs = {
        hevcRExt12bit = lib.mkForce false;
        hevcRExt10bit = lib.mkForce false;
        hevc10bit = lib.mkForce false;
        hevc = lib.mkForce false;
        av1 = lib.mkForce false;
      };
    };
  };
}
