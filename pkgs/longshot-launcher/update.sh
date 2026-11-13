#!/usr/bin/env bash
# LongshotLauncher nightlies land several times a day on the project's own
# Forgejo, next to rc tags, so tag sorting cannot pick the channel. Ask the
# releases API for the newest nightly that actually ships the linux AppImage
# and pin the version to its tag. curl and jq come from nix, so the script
# only needs nix and nix-update on PATH.
set -euo pipefail
attr="${1:-${UPDATE_NIX_ATTR_PATH:-longshot-launcher}}"

latest="$(
  nix shell nixpkgs#curl nixpkgs#jq -c sh -c \
    'curl -fsS "https://git.magicbean.dev/api/v1/repos/MagicBeanDev/LongshotLauncher/releases?limit=50" | jq -r '\''[.[] | select(.tag_name | startswith("nightly-")) | select(.tag_name as $t | any(.assets[]?; .name == "LongshotLauncher-" + $t + "-x86_64.AppImage"))][0].tag_name'\'''
)"

exec nix-update --flake --version="$latest" "$attr"
