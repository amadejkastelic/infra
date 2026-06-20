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
# Format all Nix files
treefmt

# Pre-commit hooks (run automatically on commit)
nix-shell -p pre-commit --run "pre-commit run --all-files"
```

### Building and Testing
```bash
# Build and apply system configuration
sudo nixos-rebuild switch --flake .#ryzen

# Test configuration without applying
sudo nixos-rebuild test --flake .#ryzen

# Build specific hosts
nix build .#nixosConfigurations.ryzen.config.system.build.toplevel
```

### Development Shell
```bash
# Enter dev shell with tools (nixd, nixfmt, git, repl)
nix develop
```

### Build Custom Packages
```bash
nix build .#catppuccin-plymouth
nix build .#wl-ocr
nix build .#bibata-cursors-svg
```

## Code Style and Conventions

### Nix Formatting
- **Formatter:** `nixfmt-rfc-style` (RFC-style formatting)
- **Run automatically:** Pre-commit hooks ensure formatting
- **Manual command:** `nix fmt`

### Prettier
- **Excludes:** `.js`, `.md`, `.ts` files
- **Formats:** Other files in repository

### Code Patterns
- **Modular architecture:** Separate `system/`, `home/`, `hosts/`, `modules/`, `pkgs/`
- **Flake-parts:** Uses flake-parts for modular flake configuration
- **No comments:** Keep code self-documenting, avoid adding comments unless explicitly requested

## Project Structure

```
├── home/                  # Home Manager configurations
│   ├── programs/          # User programs (browsers, games, media)
│   ├── services/          # User services (notifications, media controls)
│   ├── terminal/          # Terminal apps and shell config
│   └── theme/             # Theming and appearance
├── hosts/                 # Host-specific configurations
│   ├── ryzen/             # Desktop (Hyprland, gaming, dev)
│   └── server/            # Server (Docker, bots)
├── system/                # NixOS system modules
│   ├── core/              # Essential system configuration
│   ├── hardware/          # Hardware-specific modules
│   ├── network/           # Network services (Tailscale, etc.)
│   ├── programs/          # System-wide programs
│   └── services/          # System services (nginx, etc.)
├── lib/                   # Custom library functions
├── modules/               # Custom NixOS/Home Manager modules
│   └── services/          # Custom service modules (tailscale-tls, etc.)
└── pkgs/                  # Custom package definitions
```

## Key Technologies

- **NixOS:** System configuration
- **Home Manager:** User-space configuration
- **flake-parts:** Modular flake management
- **sops-nix:** Encrypted secrets management
- **Hyprland:** Wayland compositor
- **Catppuccin:** Consistent theming
- **Tailscale:** VPN and networking

## Common Tasks

### Adding a New Host
1. Create `hosts/<hostname>/default.nix`
2. Import required profiles (desktop/server)
3. Add to `hosts/flake.nix` if using hosts directory

### Creating a Custom Module
1. Add to `modules/` or subdirectories (e.g., `modules/services/`)
2. Follow existing module patterns
3. Import in appropriate host or profile

### Adding a Custom Package
1. Add to `pkgs/` directory
2. Create package definition following Nixpkgs patterns
3. Reference in flake outputs

## Important Notes

- **Secrets:** Encrypted with sops-nix, never commit secrets directly
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
