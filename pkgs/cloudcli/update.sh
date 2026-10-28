#!/usr/bin/env bash
# Discover the latest CloudCLI release from GitHub, then bump the package
# (nix-update re-fetches the tag tarball and auto-fixes npmDepsHash). curl and
# jq are pulled from nix, so the script only needs nix + nix-update on PATH.
set -euo pipefail
attr="${1:-${UPDATE_NIX_ATTR_PATH:-cloudcli}}"
latest="$(nix shell nixpkgs#curl nixpkgs#jq -c sh -c 'curl -fsS https://api.github.com/repos/siteboon/claudecodeui/releases/latest | jq -r .tag_name')"
latest="${latest#v}"
exec nix-update --flake --version="$latest" "$attr"
