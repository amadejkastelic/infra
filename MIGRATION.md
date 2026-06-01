# Dendritic / den migration — verification & handoff

This branch converts the config from the old type-organized layout (`home/`,
`system/`, `hosts/`, `modules/services`) to the **den** aspect-oriented dendritic
pattern. Every feature is now a `den.aspects.<name>` under `modules/<feature>/`,
auto-imported by `import-tree`. **It was written without a local Nix to eval
against — you must verify the build.** See risks at the bottom.

## What changed (structure)

- `flake.nix` `outputs` → `mkFlake (import-tree ./modules)`. New inputs added:
  `import-tree`, `den`, `flake-file`, `pkgs-by-name-for-flake-parts`, `deploy-rs`.
  The `hm` input was **renamed to `home-manager`** (den hardcodes that name).
- `modules/dendritic.nix` — den + flake-file bridge.
- `modules/systems.nix`, `modules/flake-parts/{nixpkgs,devshell,fmt,deploy}.nix` — infra.
- Foundational aspects: `modules/{base,network,secrets,users/amadejk}` (hand-written,
  these are the canonical examples).
- ~100 feature aspects under `modules/<feature>/` (shell, cli, editors, home/*,
  desktop-*, hardware, server/*, gaming, virtualisation, nas, laptop, darwin/*, theme…).
- Custom packages moved to `pkgs/by-name/<name>/package.nix` (now `pkgs.local.<name>`).
- Hosts: `modules/hosts/{ryzen,aspire,razer,oblak,m3pro}/default.nix` declare
  `den.hosts.<sys>.<host>` + a host aspect whose `provides.to-users.includes` selects
  features. Host-only hardware lives in `_`-prefixed files (import-tree skips `/_`).
- Secrets relocated to `modules/secrets/{common,home}.yaml` + `modules/hosts/razer/secrets.yaml`;
  `.sops.yaml` path_regex updated (ciphertext unchanged — keys still valid).

## REQUIRED first step — regenerate the lock

`flake.nix` inputs changed (rename + 5 new), so `flake.lock` is stale:

```sh
nix flake lock        # adds home-manager/den/flake-file/import-tree/pkgs-by-name/deploy-rs, drops hm
```

## Verify (do these in order)

1. **Eval the flake graph:**
   ```sh
   nix flake show
   ```
   Expect `nixosConfigurations.{ryzen,aspire,razer,oblak}`, `darwinConfigurations.m3pro`,
   `packages.*`, `deploy`. There should be **no** `homeConfigurations` (system-only HM by design).

2. **Validate the den API on m3pro FIRST** (least-tested path — darwin + HM):
   ```sh
   darwin-rebuild build --flake .#m3pro      # on the mac
   ```
   If den's option names differ from what's used here (it's pre-1.0), this surfaces it
   early before you trust the 100+ feature files. Fix the pattern in the 4 foundational
   aspects + hosts, then re-check.

3. **Build each NixOS host:**
   ```sh
   nix build .#nixosConfigurations.ryzen.config.system.build.toplevel
   nix build .#nixosConfigurations.aspire.config.system.build.toplevel
   nix build .#nixosConfigurations.razer.config.system.build.toplevel
   nix build .#nixosConfigurations.oblak.config.system.build.toplevel
   ```

4. **Custom packages:** `nix build .#repl` (and a couple others). Confirm `pkgs.local.*`
   resolves inside aspects (the overlay is wired in `modules/base`).

5. **deploy-rs:** `nix run github:serokell/deploy-rs -- --dry-activate .#razer` (NixOS hosts only).

## Known risks / things to check (I could NOT eval these)

- **den is pre-1.0.** The exact option API (`den.aspects.<n>.{os,nixos,darwin,homeManager,user}`,
  `provides.to-users.includes`, `den.hosts.<sys>.<host>.users.<u>`) was reconstructed from den's
  source + drupol/danielgafni configs. If an option name is off, expect a clear module error.
  **Pin `den` to a known-good rev** once it builds.
- **Per-host `includes` are approximate.** They were assembled from the old role lists
  (`system/default.nix`) + HM profiles. Some bundles add a little extra (e.g. `desktop-services`
  pulls udiskie/power-monitor). Prune/add to taste per host.
- **m3pro HM is conservative.** Linux-only home aspects (gtk, qt, wayland, hyprland, games,
  media/noisetorch) are intentionally excluded from m3pro. The old config disabled most of these
  on darwin anyway. Add back any mac-safe ones you want.
- **Unwrapped platform conditionals.** Several home aspects had `lib.mkIf (!isDarwin)` removed
  (they're Linux-only now and only included on Linux hosts). If you include one on m3pro, it may
  pull Linux-only packages — check before adding.
- **HM on servers disabled.** razer/oblak set `users.amadejk.classes = [ ]` (no home-manager,
  matching the old config). Change to `[ "homeManager" ]` if you want HM there.
- **base sets `home-manager.useGlobalPkgs/useUserPackages/backupFileExtension`** while den's HM
  battery imports the HM module — if den also sets these you may get a merge conflict; drop the
  base copy if so.
- **flake-file not fully adopted.** `flake.nix` is still hand-maintained and authoritative. Only
  the new framework inputs declare `flake-file.inputs`. To finish: move the remaining `inputs`
  into per-module `flake-file.inputs` and run `nix run .#write-flake`.

## Cleanup — ONLY after all hosts build

The old trees are left in place as reference (they are NOT imported by import-tree, so harmless).
Once every host builds, remove them:

```sh
git rm -r home system hosts pre-commit-hooks.nix treefmt.toml
git rm -r pkgs/repl pkgs/wl-ocr pkgs/bibata-cursors-svg pkgs/sekiro-fps-unlock \
          pkgs/openrgb-rc pkgs/z-ai-vision-mcp-server pkgs/magewell-usb-capture \
          pkgs/ib-edavki pkgs/jellyfin-plugin-intro-skipper \
          pkgs/jellyfin-plugin-file-transformation pkgs/hyprvoice pkgs/default.nix
git rm lib/default.nix lib/vfio.nix lib/virtualisation.nix    # keep lib/colors/ and lib/repl.nix
```

(`lib/colors/` is used by the base overlay; `lib/repl.nix` by `pkgs/by-name/repl`.)
