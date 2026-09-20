#!/usr/bin/env bash
# Tags look like "<branch>/v<version>" (e.g. 12.0/v12.0.4.0), where the
# branch is pinned in default.nix. Only consider
# tags on that branch, bump version + src (nix-update also re-hashes
# pnpmDeps), then regenerate the nuget deps.json in place.
set -euo pipefail
attr="${1:-${UPDATE_NIX_ATTR_PATH:-jellyfin-plugin-intro-skipper}}"
tag="$(nix eval --raw ".#$attr.src.tag")"
branch="${tag%/v*}"
nix-update --flake --version-regex "^${branch//./\\.}/v(.*)$" "$attr"
git diff --quiet -- "pkgs/$attr" || "$(nix build --no-link --print-out-paths ".#$attr.fetch-deps")" "pkgs/$attr/deps.json"
