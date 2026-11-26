#!/usr/bin/env bash
# Tags look like "v<version>" (e.g. v16). Bump version + src, then
# regenerate the nuget deps.json in place.
set -euo pipefail
attr="${1:-${UPDATE_NIX_ATTR_PATH:-jellyfin-plugin-kodisyncqueue}}"
nix-update --flake --version-regex '^v(.*)$' "$attr"
git diff --quiet -- "pkgs/$attr" || "$(nix build --no-link --print-out-paths ".#$attr.fetch-deps")" "pkgs/$attr/deps.json"
