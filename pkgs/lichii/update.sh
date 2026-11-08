#!/usr/bin/env bash
# Lichii tags mix schemes (build-*, nx2-*), so tag sorting cannot find the
# newest release. Ask the releases API for the latest one that actually ships
# the linux AppImage and pin the version to its tag. curl and jq come from
# nix, so the script only needs nix and nix-update on PATH.
set -euo pipefail
attr="${1:-${UPDATE_NIX_ATTR_PATH:-lichii}}"

latest="$(
  nix shell nixpkgs#curl nixpkgs#jq -c sh -c \
    'curl -fsS "https://api.github.com/repos/zortos293/Lichii/releases?per_page=30" | jq -r '\''[.[] | select((.assets[]?.name) == "lichii-linux-x86_64-pgo.AppImage")][0].tag_name'\'''
)"

exec nix-update --flake --version="$latest" "$attr"
