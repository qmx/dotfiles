# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a declarative macOS configuration using Nix flakes. It follows a layered architecture pattern where reusable base configurations live in `../core.nix` and personal/context-specific overrides live here in `dotfiles`.

## Architecture Pattern

### Two-Repository Structure

**../core.nix** (base configuration):
- Exports `nix-darwin` and `home-manager` outputs in flake.nix
- Contains tool-specific modules organized by directory (e.g., `home-manager/git/`, `home-manager/zsh/`)
- Each tool module is in its own directory with a `default.nix`
- The top-level `home-manager/default.nix` imports all tool modules
- Same pattern for `nix-darwin/` modules
- No personal information (git identity, SSH keys, etc.)

**./dotfiles** (this repo - personal overrides):
- Imports core.nix as a flake input
- Adds personal configuration in `modules/` directory
- Host-specific config in `hosts/<hostname>/` directories
- Personal data: git userEmail, signing keys, machine-specific packages

### Directory Structure

```
dotfiles/
├── flake.nix                          # Flake outputs for darwin and home-manager
├── nixpkgs.nix                        # nixpkgs configuration (unfree, overlays)
├── hosts/
│   └── <hostname>/                    # e.g., meduseld/
│       ├── nix-darwin/default.nix     # Host-specific darwin config
│       └── home-manager/default.nix   # Host-specific home-manager config
└── modules/
    ├── nix-darwin/default.nix         # Personal darwin modules
    └── home-manager/default.nix       # Personal home-manager modules

core.nix/
├── flake.nix                          # Exports nix-darwin and home-manager
├── nix-darwin/
│   ├── default.nix                    # Imports all nix-darwin modules
│   ├── fonts/default.nix
│   ├── homebrew/default.nix
│   └── system/default.nix
└── home-manager/
    ├── default.nix                    # Imports all home-manager modules
    ├── git/default.nix
    ├── zsh/default.nix
    ├── neovim/default.nix
    └── <tool>/default.nix             # One directory per tool
```

### Flake Integration Pattern

**dotfiles/flake.nix** structure:
```nix
{
  inputs = {
    core.url = "path:../core.nix";  # or "github:user/core.nix"
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = { ... };
    nix-darwin = { ... };
  };

  outputs = { core, nixpkgs, home-manager, nix-darwin, ... }: {
    # Darwin configuration (system-level)
    darwinConfigurations."<hostname>" = nix-darwin.lib.darwinSystem {
      modules = [
        core.nix-darwin           # Base configuration
        ./modules/nix-darwin      # Personal overrides
        ./hosts/<hostname>/nix-darwin  # Host-specific overrides
      ];
    };

    # Home Manager configuration (user-level)
    homeConfigurations."<username>" = home-manager.lib.homeManagerConfiguration {
      modules = [
        core.home-manager         # Base configuration
        ./modules/home-manager    # Personal overrides
        ./hosts/<hostname>/home-manager  # Host-specific overrides
      ];
    };
  };
}
```

**core.nix/flake.nix** structure:
```nix
{
  outputs = { ... }: {
    nix-darwin = ./nix-darwin;      # Points to directory with default.nix
    home-manager = ./home-manager;  # Points to directory with default.nix
  };
}
```

### Module Organization

Each configuration has three layers (in order of precedence):

1. **core.nix modules**: Base configuration for all tools
2. **modules/ overrides**: Personal defaults that apply to all hosts
3. **hosts/<hostname>/ overrides**: Machine-specific configuration

Later modules can override settings from earlier modules.

## Build and Deployment

### System Configuration (nix-darwin)

```bash
# Apply system configuration changes
sudo darwin-rebuild switch --flake .

# Build without activating
darwin-rebuild build --flake .

# Target specific host (if not current hostname)
sudo darwin-rebuild switch --flake .#<hostname>
```

### User Configuration (home-manager)

```bash
# Apply user environment changes
home-manager switch --flake .

# Target specific user
home-manager switch --flake .#<username>

# Check for home-manager news
home-manager news --flake .
```

### Flake Management

```bash
# Update all inputs (nixpkgs, home-manager, nix-darwin, core.nix)
nix flake update

# Update only core.nix input
nix flake lock --update-input core

# Check flake for errors
nix flake check
```

### Development Shell

This repo provides a dev shell with darwin-rebuild and home-manager commands:

```bash
nix develop
```

## Porting from nixos-config

When porting configuration from `../nixos-config`, follow this pattern:

### What Goes in core.nix

- Tool configurations without personal data:
  - Shell configuration (zsh setup, oh-my-zsh plugins, history settings)
  - Editor configurations (neovim plugins, settings)
  - CLI tool configurations (direnv, bat, ripgrep)
  - Git configuration WITHOUT user.email or signing keys
  - GPG agent configuration
  - Package lists for common development tools

- System configurations:
  - Font packages
  - Homebrew setup (enable, basic settings)
  - System defaults (nix settings, experimental features)

### What Stays in dotfiles

- Personal data in `modules/home-manager/default.nix`:
  - `programs.git.userEmail`
  - `programs.git.signing.key`
  - `programs.git.extraConfig` (signing configuration)
  - Additional personal packages in `home.packages`

- Machine-specific in `hosts/<hostname>/nix-darwin/default.nix`:
  - `homebrew.casks` (GUI applications)
  - `homebrew.masApps`
  - `system.stateVersion`
  - `ids.gids.nixbld` (if needed for existing installations)

- Machine-specific in `hosts/<hostname>/home-manager/default.nix`:
  - Usually empty unless host needs specific user packages

### Migration Steps

1. Identify reusable configuration in nixos-config
2. Extract to core.nix as individual tool modules
3. Each tool gets its own directory in `core.nix/home-manager/<tool>/default.nix`
4. Import the new module in `core.nix/home-manager/default.nix`
5. Override personal settings in `dotfiles/modules/home-manager/default.nix`
6. Add machine-specific settings in `dotfiles/hosts/<hostname>/`

### Example: Git Configuration

**core.nix/home-manager/git/default.nix**:
```nix
{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "Default Name";  # Will be overridden
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
```

**dotfiles/modules/home-manager/default.nix**:
```nix
{ ... }: {
  programs.git = {
    userEmail = "your@email.com";
    signing.key = "ssh-ed25519 AAAA...";
  };
}
```

## Current State from nixos-config

The existing nixos-config has:
- Machine configuration: `machines/meduseld.nix`
- User configuration: `users/qmx/darwin.nix` and `users/qmx/home-manager.nix`
- System builder: `lib/mksystem.nix` (not needed with new pattern)

These need to be split:
- Reusable parts → core.nix
- Personal overrides → dotfiles/modules/
- Machine-specific → dotfiles/hosts/meduseld/

## Key Conventions

### Module Structure

- Each tool module is self-contained in its own directory
- Module file is always named `default.nix`
- Modules can have additional files (e.g., `init.zsh`, config files)
- Use `builtins.readFile` to include external files

### Naming

- Hosts use lowercase names (e.g., `meduseld`)
- Module directories use lowercase tool names (e.g., `git`, `zsh`, `neovim`)
- No `machines/` directory, use `hosts/` instead
- No per-user directories, usernames are passed via specialArgs

### Package Management

- **Nix-managed**: Development tools, CLI utilities, language servers
- **Homebrew-managed**: GUI applications, Mac App Store apps
- Homebrew configuration in `modules/nix-darwin/default.nix` for personal casks
- Base homebrew setup in `core.nix/nix-darwin/homebrew/default.nix`

### SpecialArgs Usage

Pass configuration parameters through flake:

```nix
specialArgs = { inherit username; };          # nix-darwin
extraSpecialArgs = { inherit username homeDirectory; };  # home-manager
```

Access in modules:

```nix
{ username, homeDirectory, ... }: {
  home.username = username;
  home.homeDirectory = homeDirectory;
}
```

## Important Notes

- Always test with `build` before `switch` to catch errors
- `core.nix` input can use `path:../core.nix` for local development
- For production, change to `github:user/core.nix` reference
- The `nixpkgs.nix` file configures allowUnfree and overlays
- Darwin configurations require `sudo`, home-manager does not
- Home Manager creates `.backup` files when overwriting existing files
- Use `nix-darwin.lib.darwinSystem` directly, no custom builder function needed
