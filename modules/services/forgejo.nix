{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.forgejo.provision;
  forgejoCfg = config.services.forgejo;
  port = toString forgejoCfg.settings.server.HTTP_PORT;

  provision = pkgs.writeShellScript "forgejo-provision" ''
    url="http://127.0.0.1:${port}"
    exe="${lib.getExe forgejoCfg.package}"
    awk="${lib.getExe pkgs.gawk}"
    curl="${lib.getExe pkgs.curl}"
    jq="${lib.getExe pkgs.jq}"

    pw_file="$CREDENTIALS_DIRECTORY/provision-password"
    if [ ! -r "$pw_file" ]; then
      echo "forgejo provision: password credential missing, skipping"
      exit 0
    fi
    pw=$(cat "$pw_file")

    if ! "$exe" admin user list | grep -wq "${cfg.adminUsername}"; then
      "$exe" admin user create \
        --admin \
        --username "${cfg.adminUsername}" \
        --email "${cfg.adminEmail}" \
        --password "$pw" \
        --must-change-password=false \
        || echo "forgejo provision: failed to create admin user '${cfg.adminUsername}'"
    fi

    keys='${lib.concatStringsSep "\n" cfg.sshKeys}'
    while IFS= read -r key; do
      [ -z "$key" ] && continue
      keyData=$(printf '%s' "$key" | "$awk" '{print $1" "$2}')
      if "$curl" -fsu "${cfg.adminUsername}:$pw" "$url/api/v1/users/${cfg.adminUsername}/keys" \
        | "$jq" -r '.[].key' | "$awk" '{print $1" "$2}' | grep -qF -- "$keyData"
      then
        echo "forgejo provision: key already present $keyData"
      else
        "$curl" -fsu "${cfg.adminUsername}:$pw" -X POST \
          "$url/api/v1/admin/users/${cfg.adminUsername}/keys" \
          -H "Content-Type: application/json" \
          --data "$("$jq" -n --arg k "$key" '{title:"personal", key:$k}')" \
          && echo "forgejo provision: added key $keyData" \
          || echo "forgejo provision: failed to add key $keyData"
      fi
    done <<< "$keys"

    exit 0
  '';
in
{
  options.services.forgejo.provision = {
    enable = lib.mkEnableOption "provisioning of the initial Forgejo admin user and SSH keys";

    adminUsername = lib.mkOption {
      type = lib.types.str;
      description = "Admin username to create (also used for SSH key ownership).";
    };

    adminEmail = lib.mkOption {
      type = lib.types.str;
      description = "Email address for the admin user.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        File containing the admin password. Loaded as a systemd credential
        of the forgejo service (root-readable), so a default sops secret works.
      '';
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys to register on the admin account.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.forgejo = {
      serviceConfig = {
        LoadCredential = [ "provision-password:${cfg.passwordFile}" ];
        ExecStartPost = [ "${provision}" ];
      };
    };
  };
}
