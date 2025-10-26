# dotfiles

Personal macOS configuration using Nix flakes, nix-darwin, and home-manager.

This repository contains my personal system and user configurations, built on top of [core.nix](https://github.com/qmx/core.nix) for reusable base configurations.

## Architecture

This follows a **layered configuration pattern**:

1. **Base layer**: [core.nix](https://github.com/qmx/core.nix) - Reusable tool configurations
2. **Personal layer**: `modules/` - Personal overrides and additions
3. **Host layer**: `hosts/meduseld/` - Machine-specific settings

## Structure

```
dotfiles/
├── flake.nix                          # Flake configuration
├── flake.lock                         # Locked input versions
├── nixpkgs.nix                        # nixpkgs configuration
├── modules/
│   ├── nix-darwin/default.nix         # Personal system settings
│   └── home-manager/default.nix       # Personal user settings
└── hosts/
    └── meduseld/                      # Host-specific config
        ├── nix-darwin/default.nix     # System config for this host
        └── home-manager/default.nix   # User config for this host
```

## Quick Start

### Prerequisites

1. Install Nix with flakes enabled
2. Install nix-darwin
3. Install home-manager

### System Configuration

Apply system-level changes:

```bash
sudo darwin-rebuild switch --flake .
```

### User Configuration

Apply user environment changes:

```bash
home-manager switch --flake .
```

### Development Shell

Enter a shell with darwin-rebuild and home-manager available:

```bash
nix develop
```

## Configuration Layers

### Core Layer (from core.nix)

Base configurations for:
- Git, Neovim, Zsh, Tmux
- Direnv, Starship, GitHub CLI
- System fonts and preferences
- GPG agent setup

### Personal Layer (modules/)

Personal customizations:
- Git identity and signing configuration
- Additional packages (yubikey tools, media tools, etc.)
- Environment variables
- Shell customizations (chruby, cargo, rancher desktop)

### Host Layer (hosts/meduseld/)

Machine-specific settings:
- System state version
- Architecture (aarch64-darwin)
- GUI applications (homebrew casks)
- System packages

## Updating

### Update all inputs (nixpkgs, home-manager, nix-darwin, core.nix)

```bash
nix flake update
```

### Update only core.nix

```bash
nix flake update core
```

### Check for configuration issues

```bash
nix flake check
```

### View home-manager news

```bash
home-manager news --flake .
```

## Adding New Tools

### Add a system package

Edit `hosts/meduseld/nix-darwin/default.nix`:

```nix
environment.systemPackages = with pkgs; [
  neovim
  git
  your-new-package  # Add here
];
```

### Add a user package

Edit `modules/home-manager/default.nix`:

```nix
home.packages = with pkgs; [
  cmake
  your-new-tool  # Add here
];
```

### Add a homebrew cask

Edit `modules/nix-darwin/default.nix`:

```nix
homebrew.casks = [
  "ghostty"
  "your-app"  # Add here
];
```

---

*Based on the modular configuration pattern from [Jitsusama's dotfiles](https://github.com/Jitsusama/dotfiles).*
