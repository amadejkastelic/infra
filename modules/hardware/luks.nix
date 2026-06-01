{
  den.aspects.luks.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.boot.initrd.luks.fido2;
      uuidPattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
    in
    {
      options.boot.initrd.luks.fido2 = {
        enable = lib.mkEnableOption "Enable LUKS fido2 support";

        device = lib.mkOption {
          type = lib.types.strMatching uuidPattern;
          example = "836e758a-4fe0-4e78-a965-edfcf1f1445a";
          description = "UUID of the LUKS device (without /dev/disk/by-uuid/ prefix)";
        };

        extraOpts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of extra crypttab options";
        };
      };

      config = lib.mkIf cfg.enable {
        boot.initrd = {
          systemd.enable = true;

          luks.devices."luks-${cfg.device}" = {
            device = "/dev/disk/by-uuid/${cfg.device}";
            crypttabExtraOpts = [ "fido2-device=auto" ] ++ cfg.extraOpts;
          };
        };
      };
    };
}
