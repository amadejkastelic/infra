host := `hostname`

update:
    nix flake update --commit-lock-file

[linux]
upgrade TARGET=host:
    #!/usr/bin/env bash
    if [ "{{TARGET}}" = "{{host}}" ]; then
        nixos-rebuild switch \
            --flake .#{{TARGET}} \
            --sudo
    else
        nixos-rebuild switch \
            --flake .#{{TARGET}} \
            --target-host amadejk@{{TARGET}} \
            --sudo
    fi

[macos]
upgrade TARGET=host:
    sudo darwin-rebuild switch --flake .#{{TARGET}}

gc FLAGS='':
    nix-collect-garbage {{FLAGS}}
