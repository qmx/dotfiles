# YubiKey Setup

This document covers YubiKey SSH authentication setup for different platforms.

## NixOS

Import the YubiKey module in your host's NixOS config:

```nix
imports = [
  ../../../modules/nixos/yubikey.nix
];
```

This automatically configures:
- `plugdev` group and user membership
- `pcscd` smart card daemon with CCID driver
- udev rules for YubiKey USB access

## Non-NixOS Linux (Debian, etc.)

### 1. Import the role in home-manager config

```nix
imports = [
  ../../../roles/linux-yubikey/home-manager
];
```

This configures:
- SSH agent to prefer local YubiKey via gpg-agent
- Fallback to forwarded SSH agent when YubiKey unavailable
- Generates udev rules at `~/.config/yubikey-udev/70-yubikey-usb.rules`

### 2. Install system packages

```bash
sudo apt install pcscd libccid
```

### 3. Add user to plugdev group

```bash
sudo usermod -aG plugdev $USER
```

Log out and back in for group membership to take effect.

### 4. Install udev rules

```bash
sudo cp ~/.config/yubikey-udev/70-yubikey-usb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

Then unplug and replug your YubiKey.

### 5. Verify

```bash
gpg --card-status
ssh-add -L
```

## Troubleshooting

**"No card" or permission errors:**
- Check group membership: `groups` should include `plugdev`
- Verify udev rules are installed: `ls /etc/udev/rules.d/70-yubikey*`
- Try unplugging and replugging YubiKey after rule changes

**gpgconf not found:**
- Ensure `gnupg` is in your packages (the role adds this automatically)
