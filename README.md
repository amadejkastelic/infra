# NixOS & Home Manager Dotfiles

Personal NixOS and Home Manager configuration using flake-parts for a modular, reproducible system setup.

<img width="5120" height="1440" alt="20260203_185658" src="https://github.com/user-attachments/assets/5c87ec52-7c7a-4e9a-82a9-a4ea9a6470b5" />

## Features

- **NixOS Configuration**: Complete system configuration for desktop and server environments
- **Home Manager Integration**: User-space configuration management
- **Hyprland Desktop**: Modern Wayland compositor with comprehensive theming
- **Catppuccin Theme**: Consistent theming across all applications
- **Gaming Setup**: Steam, GameMode, Gamescope, and various gaming tools
- **Development Envgironment**: Pre-configured editors (Neovim, VSCode), terminal tools (Nushell, Ghostty), and AI agents
- **AI Integration**: Opencode with MCPs
- **Secret Management**: Encrypted secrets using sops-nix
- **Pre-commit Hooks**: Automated code formatting and linting

## Hosts

- **ryzen**: Main desktop configuration with Hyprland, gaming, and development tools
- **aspire**: Laptop configuration with Hyprland and power management
- **razer**: Server setup with media services (Immich, Jellyfin), and *arr stack
- **oblak**: NAS configuration with NFS shares and storage management

## Structure

```
├── flake.nix              # Main flake configuration
├── home/                  # Home Manager configurations
│   ├── editors/           # Editor configurations (Neovim, VSCode)
│   ├── profiles/          # Host-specific home profiles
│   ├── programs/          # User programs (browsers, media, office, etc.)
│   ├── services/          # User services (notifications, media controls, wayland)
│   ├── terminal/          # Terminal apps, shell, and AI agents
│   └── theme/             # Theming and appearance
├── hosts/                 # Host-specific configurations
│   ├── aspire/            # Laptop configuration
│   ├── common/            # Shared host configuration and secrets
│   ├── oblak/             # NAS configuration
│   ├── razer/             # Server configuration
│   └── ryzen/             # Desktop configuration
├── system/                # NixOS system modules
│   ├── core/              # Essential system configuration
│   ├── hardware/          # Hardware-specific modules
│   ├── network/           # Network services
│   ├── programs/          # System-wide programs
│   └── services/          # System services
├── lib/                   # Custom library functions
├── modules/               # Custom NixOS/Home Manager modules
└── pkgs/                  # Custom package definitions
```

## Usage

### Building System Configuration

```bash
# Build and switch to new configuration
sudo nixos-rebuild switch --flake .#ryzen

# Test configuration without switching
sudo nixos-rebuild test --flake .#ryzen

# Build specific hosts
nix build .#nixosConfigurations.ryzen.config.system.build.toplevel
```

### Development Environment

```bash
# Enter development shell with tools
nix develop

# Format all Nix files
treefmt

# Build custom packages
nix build .#catppuccin-plymouth
nix build .#wl-ocr
nix build .#bibata-cursors-svg
```

## Development Tools

The development shell includes:
- **nixd**: Nix language server
- **nixfmt**: Code formatter
- **git**: Version control
- **just**: Command runner
- **repl**: Custom REPL for configuration testing

## Theming

Consistent Catppuccin theming across:
- Window manager (Hyprland)
- Terminal applications
- GTK/Qt applications
- Web browsers
- Development tools

## Secret Management

Secrets are encrypted using sops-nix:
- `home/secrets.yaml` - Home Manager secrets
- `hosts/common/secrets.yaml` - Common host secrets

Update secret keys:
```bash
nix-shell -p sops --run "sops updatekeys path/to/secrets.yaml"
```

## Key Applications

### Desktop Environment
- **Hyprland**: Wayland compositor with plugins (dynamic-cursors, hyprlux, hyprvibr)
- **Noctalia**: Shell and notification daemon
- **Vicinae**: Application launcher and AI assistant interface
- **hypridle/hyprlock**: Idle management and screen lock

### Development
- **Neovim**: Text editor with LSP support
- **VSCode**: IDE with extensions (also VSCode server support)
- **Git**: Version control with custom configuration
- **Ghostty**: Terminal emulator
- **Nushell**: Modern shell with structured data
- **AI Agents**: Claude, opencode, and MCP integration

### Media & Gaming
- **Steam**: Gaming platform with Proton
- **MPV**: Media player
- **Cider**: Music streaming
- **OBS**: Screen recording
- **GameMode**: Performance optimization

### Productivity
- **Zen Browser**: Firefox-based browser
- **Thunderbird**: Email client
- **Zathura**: PDF viewer
- **Nautilus/Thunar**: File managers


## License

This configuration is available under the terms specified in the LICENSE file.

## Contributing

This is a personal dotfiles repository, but feel free to:
- Use any parts of this configuration for your own setup
- Report issues or suggest improvements
- Submit pull requests for bug fixes

## System Profiles

The configuration provides four system profiles:

- **desktop**: Full desktop environment with Hyprland, gaming, and development tools
- **laptop**: Desktop profile plus power management
- **server**: Docker, media services, and web services
- **nas**: Network storage with NFS and basic services

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Stylix](https://github.com/danth/stylix)
