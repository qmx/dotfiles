# homebridge

Nix packages and home-manager module for Homebridge with declarative configuration.

## Features

- Homebridge packages built with Nix
- Declarative configuration via home-manager
- Runs as user service (no root needed)
- Linux only (uses systemd user services)
- Included plugin: homebridge-camera-ffmpeg

## Usage

Enable in your home-manager configuration:

```nix
{
  services.homebridgeNix = {
    enable = true;

    config = {
      bridge = {
        name = "My Homebridge";
        username = "AA:BB:CC:DD:EE:FF";
        port = 51826;
        pin = "123-45-678";
      };

      platforms = [
        {
          platform = "Camera-ffmpeg";
          cameras = [
            {
              name = "Front Door";
              videoConfig.source = "-i rtsp://camera.local/stream";
            }
          ];
        }
      ];
    };

    plugins = with pkgs; [ homebridge-camera-ffmpeg ];
  };
}
```

After installation, enable and start the service:

```bash
systemctl --user enable --now homebridgeNix
systemctl --user status homebridgeNix
```

Configuration is stored in `~/.local/share/homebridge/`.

## Available Plugins

- `homebridge-camera-ffmpeg` - FFmpeg-based IP camera support

## Supported Systems

**home-manager module (Linux only):**
- `x86_64-linux`, `aarch64-linux`

**Packages (build on any system):**
- `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`
