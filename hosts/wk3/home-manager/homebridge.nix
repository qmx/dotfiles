{ pkgs, homebridge, secrets, ... }:
{
  # Import the homebridge home-manager module
  imports = [
    homebridge.homeManagerModules.default
  ];

  # Add homebridge overlay to make packages available
  nixpkgs.overlays = [
    homebridge.overlays.default
  ];

  # Configure homebridge service
  services.homebridgeNix = {
    enable = true;

    config = {
      bridge = {
        name = "Homebridge-dev";
        username = secrets.homebridge.bridge.username;
        port = 51826;
        pin = secrets.homebridge.bridge.pin;
        advertiser = "bonjour";
      };
      accessories = [];
      platforms = [
        {
          platform = "Camera-ffmpeg";
          name = "Camera FFmpeg";
          videoProcessor = "ffmpeg";
          debug = true;
          cameras = map (cam: {
            name = cam.name;
            manufacturer = cam.manufacturer;
            model = cam.model;
            serialNumber = cam.serialNumber;
            videoConfig = cam.videoConfig;
          }) secrets.homebridge.cameras;
        }
      ];
    };

    # Enable camera-ffmpeg plugin
    plugins = with pkgs; [
      homebridge-camera-ffmpeg
    ];
  };
}
