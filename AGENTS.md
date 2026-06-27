# Agents Reference

This file provides guidance for AI agents working on this NixOS dotfiles repository.

## Available Agents

### General Agent (`subagent_type: "general"`)
- **Use for:** Complex multi-step tasks, parallel execution of independent operations
- **Capabilities:** Execute multiple work units in parallel, handle complex workflows
- **When to use:** Tasks requiring 3+ steps or multiple concurrent operations

### Explore Agent (`subagent_type: "explore"`)
- **Use for:** Fast codebase exploration and searching
- **Capabilities:** Find files by patterns, search code for keywords, answer codebase questions
- **Thoroughness levels:**
  - `quick`: Basic searches and file finding
  - `medium`: Moderate exploration across multiple locations
  - `very thorough`: Comprehensive analysis across multiple locations and naming conventions

## When NOT to Use Agents

Skip agents and use direct tools when:
- Reading a specific file path (use Read or Glob)
- Searching for specific class definitions (use Glob)
- Searching code within 2-3 specific files (use Read)
- Simple single-step tasks

## Development Commands

### Formatting and Linting
```bash
# Format all Nix files (canonical formatter)
treefmt

# Pre-commit hooks (run automatically on commit)
nix-shell -p pre-commit --run "pre-commit run --all-files"
```

### Building and Testing

Hosts are assembled from reusable **profiles** defined in `system/default.nix`:
`desktop`, `laptop`, `server`, `nas`. `hosts/default.nix` composes the right
profile into each host's `nixosSystem` (or `darwinSystem`) call.

NixOS hosts: `ryzen` (desktop), `aspire` (laptop), `razer` (server), `oblak` (nas).
macOS host: `m3pro` (darwin).

```bash
# Build and apply a NixOS configuration locally
sudo nixos-rebuild switch --flake .#ryzen

# Test a configuration without switching
sudo nixos-rebuild test --flake .#ryzen

# Build a host's toplevel without applying
nix build .#nixosConfigurations.ryzen.config.system.build.toplevel

# macOS host (uses nix-darwin)
sudo darwin-rebuild switch --flake .#m3pro
```

### Justfile shortcuts
```bash
just update              # nix flake update --commit-lock-file
just upgrade             # rebuild current host (local)
just upgrade ryzen       # rebuild a host; if not local, deploys over Tailscale via --target-host
just upgrade oblak       # (Linux/macOS aware; m3pro routes to darwin-rebuild)
just gc                  # nix-collect-garbage
```

### Development Shell
```bash
# Enter dev shell with tools (nixd, nixfmt, treefmt, just, git, repl)
nix develop
```

### Build Custom Packages
```bash
nix build .#repl
nix build .#wl-ocr
nix build .#bibata-cursors-svg
nix build .#sekiro-fps-unlock
nix build .#openrgb-rc
nix build .#z-ai-vision-mcp-server
nix build .#magewell-usb-capture
nix build .#ib-edavki
nix build .#jellyfin-plugin-intro-skipper
nix build .#jellyfin-plugin-file-transformation
nix build .#hyprvoice
```

## Code Style and Conventions

### Nix Formatting
- **Formatter:** `treefmt` (backed by `nixfmt-rfc-style`, configured in `treefmt.toml`)
- **Run automatically:** Pre-commit hooks ensure formatting
- **CI:** `nix flake check` runs on every push/PR via `.github/workflows/lint.yml`

### Prettier
- **Excludes:** `.js`, `.md`, `.ts` files (and `flake.lock`)
- **Formats:** Other files in repository

### Code Patterns
- **Modular architecture:** Separate `system/`, `home/`, `hosts/`, `modules/`, `pkgs/`, `lib/`
- **Flake-parts:** Uses flake-parts for modular flake configuration
- **System profiles:** `system/default.nix` exposes `desktop`, `laptop`, `server`, `nas` lists that hosts compose
- **No comments:** Keep code self-documenting, avoid adding comments unless explicitly requested

## Project Structure

```
├── flake.nix              # Main flake (flake-parts, NixOS + darwin systems)
├── Justfile               # just recipes (update, upgrade, gc)
├── .sops.yaml             # sops rules + public age keys (plain config, safe to read)
├── treefmt.toml           # nixfmt-rfc-style config
├── docs/                  # Topical docs (LUKS.md, SERVER.md)
├── .github/workflows/     # CI: lint, update-flake, upgrade-host, mirrors
├── home/                  # Home Manager configurations
│   ├── editors/           # Editor configs (neovim, vscode, zed)
│   ├── profiles/          # Host-specific home profiles (ryzen, m3pro) + homeImports
│   ├── programs/          # User programs (browsers, games, media, office, social, wayland)
│   ├── services/          # User services (gpg, media, networkmanager, system, wayland)
│   ├── terminal/          # Terminal apps, shell, emulators, AI agents
│   ├── theme/             # Theming (catppuccin, stylix)
│   └── secrets.yaml       # ENCRYPTED - do not read or write (see Secrets)
├── hosts/                 # Host-specific configurations
│   ├── aspire/            # Laptop (Hyprland, power management)
│   ├── common/            # Shared host config + secrets (secrets.nix module, secrets.yaml blob)
│   ├── m3pro/             # macOS (nix-darwin)
│   ├── oblak/             # NAS (NFS shares, storage, monitoring)
│   ├── razer/             # Server (media stack: Immich, Jellyfin, *arr)
│   ├── ryzen/             # Desktop (Hyprland, gaming, dev)
│   └── default.nix        # Wires profiles -> nixosSystem / darwinSystem
├── lib/                   # Custom library (colors, vfio, virtualisation, repl)
├── modules/               # Custom NixOS modules (config, hardware/luks, services/*)
│   ├── hardware/          # Custom hardware modules (luks.nix)
│   ├── services/          # Custom service modules (arr, forgejo, grafana, immich,
│   │                      #   jellyfin, jellyseerr, tailscale-tls, tailscale-funnel,
│   │                      #   vaultwarden, blocky, dashboard, llama-cpp, pipewire, ...)
│   ├── config.nix
│   └── default.nix
├── pkgs/                  # Custom package definitions
└── system/                # NixOS system modules
    ├── core/              # boot, lanzaboote (secure boot), security, sops, users
    ├── darwin/            # nix-darwin modules (homebrew, keyboard, preferences)
    ├── hardware/          # bluetooth, docker, input, ledger, opengl, virtualisation
    ├── network/           # avahi, nfs, syncthing, tailscale
    ├── nix/               # nix settings, substituters, cache.json, exec
    ├── programs/          # System-wide programs (fonts, hyprland, gaming, gnome, obs, ...)
    ├── services/          # System services (nginx, acme, forgejo, jellyfin, immich, arr,
    │                      #   blocky, cloudflared, dashboard, databases, metrics, nas, ...)
    ├── theme/             # System theming (catppuccin.nix, stylix.nix)
    ├── config.nix
    └── default.nix        # Exposes desktop/laptop/server/nas profile lists
```

## Key Technologies

- **NixOS:** Linux system configuration
- **nix-darwin:** macOS system configuration (`m3pro`)
- **Home Manager:** User-space configuration
- **flake-parts:** Modular flake management
- **sops-nix:** Encrypted secrets management (age)
- **disko:** Declarative disk management
- **Hyprland:** Wayland compositor (desktop/laptop)
- **Stylix:** System-wide theming engine
- **Catppuccin:** Base color scheme
- **Lanzaboote:** Secure boot for NixOS
- **Tailscale:** VPN, mesh networking, and remote deployments
- **Determinate:** Nix installer/updater
- **GitHub Actions:** CI for lint (`nix flake check`), auto flake updates, scheduled host upgrades

## Common Tasks

### Adding a New Host
1. Create `hosts/<hostname>/default.nix` (plus `disk-config.nix` / `hardware-configuration.nix` as needed)
2. Add a block in `hosts/default.nix`:
   - NixOS: `nixosSystem` composing the right profile from `system/default.nix` (`desktop` / `laptop` / `server` / `nas`) plus `./common/secrets.nix`
   - macOS: `inputs.darwin.lib.darwinSystem` (see the existing `m3pro` block)
3. If the host uses Home Manager, add a `homeImports."<user>@<host>"` entry in `home/profiles/default.nix`
4. Generate/obtain an age public key for the host and add it under `&hosts` in `.sops.yaml` so it can decrypt secrets
5. For remote upgrades via `just upgrade <host>` / CI, ensure the host is reachable on Tailscale

### Creating a Custom Module
1. Add to `modules/` under the right subdir (`services/`, `hardware/`) or `modules/config.nix`
2. Follow existing module patterns; modules are aggregated via `modules/default.nix` into `flake.modules.{config,hardware,services}`
3. Import in the relevant profile (`system/default.nix`) or host

### Adding a Custom Package
1. Create `pkgs/<name>/` with a `default.nix` (standard nixpkgs `callPackage` shape)
2. Register it in `pkgs/default.nix` under `perSystem.packages`
3. Build with `nix build .#<name>`

## Important Notes

### Secrets (CRITICAL)

**NEVER read or write any `secrets.yaml` file.** These are sops-encrypted blobs.
Opening or hand-editing them corrupts the ciphertext. This rule applies to **all**
files matching the sops rules in `.sops.yaml`, including:

- `home/secrets.yaml`
- `hosts/common/secrets.yaml`
- `hosts/ryzen/secrets.yaml`
- `hosts/razer/secrets.yaml`
- `hosts/oblak/secrets.yaml`
- any future `hosts/*/secrets.yaml`

To add or change a secret value, tell the user to run `sops <path>` themselves and
edit the value in their editor; do not attempt to do it for them.

These related files are **plain config and are safe to read/edit**:
- `.sops.yaml` — sops creation rules + **public** age keys only
- `hosts/common/secrets.nix` — Nix module that *references* sops keys by name (no secret values)

### Other
- **Pre-commit hooks:** Automatically run on commit (nixfmt, prettier)
- **Hostnames:** Public in repo, OK for Certificate Transparency
- **Single-host services:** Many services use `config.networking.hostName` for virtual hosts

## Post-Task Verification

After completing changes, run:
```bash
# Format code
treefmt

# Check for any obvious issues
nix flake check
```

If errors occur, fix and re-run. Do not commit broken configuration.
