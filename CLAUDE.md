# CLAUDE.md

**Note**: This project uses [bd (beads)](https://github.com/steveyegge/beads)
for issue tracking. Use `bd` commands instead of markdown TODOs.
See AGENTS.md for workflow details.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a declarative system configuration using Nix flakes for both macOS (via nix-darwin) and Linux (via home-manager). It follows a layered architecture pattern where reusable base configurations live in `../core.nix` and personal/context-specific overrides live here in `dotfiles`.

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

### Fetching GitHub Sources

When adding or updating GitHub-based flake inputs, use `nix-prefetch-github` to get the correct revision hash:

```bash
# Fetch latest commit from default branch
nix run nixpkgs#nix-prefetch-github -- owner repo

# Fetch specific tag or branch
nix run nixpkgs#nix-prefetch-github -- owner repo --rev v1.0.0

# Example: fetch a specific release
nix run nixpkgs#nix-prefetch-github -- NixOS nixpkgs --rev 24.05
```

### Development Shell

This repo provides a dev shell with darwin-rebuild and home-manager commands:

```bash
nix develop
```

## Configuration Organization

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
  - Linux-specific packages or configurations
  - Platform-specific settings

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

## Linux (Non-NixOS) Considerations

When deploying to non-NixOS Linux systems (like Debian):

- Home-manager can only manage user-level configuration
- System services and udev rules require manual setup
- The devShell will check for required system configuration and provide instructions
- See host-specific documentation (e.g., `hosts/wk3/home-manager/default.nix`) for system requirements

## NixOS Considerations

### Python Tools That Manage Their Own Runtime

Tools like `uv`, `pipx`, or `pyenv` download dynamically-linked Python binaries that fail on NixOS. To find nixpkgs variants tied to a specific Python version:

```bash
nix search nixpkgs <tool> | grep python
# Example: nix search nixpkgs uv | grep python
# Reveals: python312Packages.uv, python313Packages.uv, etc.
```

Use `pythonXXXPackages.<tool>` instead of the standalone package. It's built against nixpkgs Python and works correctly.

## Key Conventions

### Module Structure

- Each tool module is self-contained in its own directory
- Module file is always named `default.nix`
- Modules can have additional files (e.g., `init.zsh`, config files)
- Use `builtins.readFile` to include external files

### Configuration Files

- **NEVER inline configuration files using `home.file."...".text`**
- Always create separate configuration files and reference them with `home.file."...".source`
- Configuration files should live alongside their module's `default.nix`
- Example: For `~/.finicky.js`, create `hosts/meduseld/finicky.js` and reference it with `home.file.".finicky.js".source = ../finicky.js;`

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

## llama-swap Model Configuration

The `services.llama-swap` module manages LLM models via llama.cpp. Models are specified using HuggingFace format:

```
org/repo-GGUF:quantization
```

Examples:
- `unsloth/Qwen3-Next-80B-A3B-Instruct-GGUF:Q8_K_XL`
- `unsloth/SmolLM3-3B-128K-GGUF:Q4_K_XL`
- `unsloth/gemma-3-12b-it-qat-int4-GGUF:Q4_K_XL`

Common quantizations (smallest to largest):
- `Q4_K_M` - 4-bit, good balance of size/quality
- `Q4_K_XL` - 4-bit with larger tensors
- `Q8_K_XL` - 8-bit, higher quality
- `UD-Q8_K_XL` - 8-bit unsloth dynamic

Model configuration in `hosts/<hostname>/home-manager/default.nix`:

```nix
services.llama-swap = {
  enable = true;
  llamaCppPackage = pkgs.llama-cpp-rocm;  # for ROCm, omit for CPU/Metal
  healthCheckTimeout = 300;  # seconds to wait for model download/load
  models = {
    "Model-Name" = {
      hf = "org/repo-GGUF:quantization";
      ctxSize = 131072;  # context window size
      flashAttn = true;  # enable flash attention
      aliases = [ "short-name" ];
      extraArgs = [ "--jinja" "-ngl 99" "--temp 0.7" ];
    };
  };
};
```

Models are auto-downloaded from HuggingFace to `~/.local/share/llama-models/`.

### Adding New Models to the Catalog

**IMPORTANT**: Never guess model parameters. Always research first.

1. **Research the model** before adding:
   - Check the HuggingFace model card (e.g., `huggingface.co/unsloth/<model>-GGUF`)
   - Check official documentation (NVIDIA, Alibaba, Google, etc.)
   - Determine:
     - **Context length**: What's the max supported? What's default?
     - **Is it a thinking/reasoning model?**: Does it use `<think>` tokens?
     - **Recommended parameters**: What temp/top_p does the vendor recommend?
     - **Output limits**: What's the max output token count?

2. **Use vendor-recommended parameters**:
   - Different models have different optimal settings
   - Thinking models often need different params for reasoning vs tool calling
   - Create separate model entries if needed (e.g., `Model-Name` and `Model-Name-Tools`)

3. **Add to `lib/models.nix`**:
   ```nix
   "Model-Name" = {
     hf = "org/repo-GGUF:quantization";
     ctxSize = <researched value>;
     flashAttn = <true/false based on model>;
     aliases = [ "short-name" ];
     extraArgs = [
       "--jinja"
       "-ngl 99"
       "--temp <vendor recommended>"
       "--top-p <vendor recommended>"
     ];
     opencode = {
       displayName = "Display Name";
       reasoning = <true if thinking model>;
       toolCall = true;
       outputLimit = <researched value>;  # Don't make this up!
     };
   };
   ```

4. **Add to host's `localModels`** in `hosts/<hostname>/home-manager/default.nix`

Example research sources:
- HuggingFace model card: inference parameters, context length
- Vendor blog posts: recommended settings, use cases
- Model README: architecture details, token limits

## Secrets Management

Secrets are managed using `age` encryption and `minijinja` templating. This allows `home-manager switch` to work without the `--impure` flag.

### Architecture

```
secrets/
├── recipients.txt      # age public key (committed)
└── secrets.json.age    # encrypted secrets (committed)

templates/
├── env.j2              # exports BRAVE_API_KEY
├── opencode.json.j2    # opencode config with secrets
└── homebridge.json.j2  # homebridge config (wk3 only)

~/.secrets/             # created at activation (not committed)
├── data.json           # decrypted secrets
└── env                 # sourced by zsh
```

### Key Setup (one-time per machine)

```bash
# If you have the master key in 1Password:
mkdir -p ~/.config/age
# Paste the key from 1Password into keys.txt
chmod 600 ~/.config/age/keys.txt

# Or generate a new key (store in 1Password afterward):
nix shell nixpkgs#age -c age-keygen -o ~/.config/age/keys.txt
chmod 600 ~/.config/age/keys.txt
# Add the public key to secrets/recipients.txt
```

### Adding/Updating Secrets

```bash
# 1. Edit secrets.json (decrypted copy)
# 2. Re-encrypt:
nix shell nixpkgs#age -c age -R secrets/recipients.txt -o secrets/secrets.json.age secrets.json

# 3. Commit secrets.json.age (never commit secrets.json)
```

### Module Configuration

Enable secrets in host config:

```nix
secrets = {
  enable = true;
  encrypted = "${repoRoot}/secrets/secrets.json.age";
  envFile = "${homeDirectory}/.secrets/env";
  templates = {
    env = {
      template = "${repoRoot}/templates/env.j2";
      output = "${homeDirectory}/.secrets/env";
    };
    # For configs that need secrets + Nix-generated data:
    opencode = {
      template = "${repoRoot}/templates/opencode.json.j2";
      output = "${homeDirectory}/.config/opencode/opencode.json";
      extraData = [ config.xdg.configFile."opencode/opencode-data.json".source ];
      mode = "0644";
    };
  };
};
```

### Template Syntax (Jinja2/MiniJinja)

```jinja
{# Access secrets directly #}
export BRAVE_API_KEY={{ braveApiKey | tojson }}

{# Access nested data #}
"pin": {{ homebridge.bridge.pin | tojson }}

{# Output arrays as JSON #}
"cameras": {{ homebridge.cameras | tojson }}

{# Access Nix-generated data (via extraData) #}
"providers": {{ data.providers | tojson }}
```

## Important Notes

- Always test with `build` before `switch` to catch errors
- `core.nix` input can use `path:../core.nix` for local development
- For production, change to `github:user/core.nix` reference
- The `nixpkgs.nix` file configures allowUnfree and overlays
- Darwin configurations require `sudo`, home-manager does not
- Home Manager creates `.backup` files when overwriting existing files
- Use `nix-darwin.lib.darwinSystem` directly, no custom builder function needed
