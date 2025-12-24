{
  pkgs,
  username,
  ...
}:

{
  # Group for YubiKey access
  users.groups.plugdev = { };

  # Add user to plugdev group
  users.users.${username}.extraGroups = [ "plugdev" ];

  # Smart card daemon
  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };

  # YubiKey packages and udev rules
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.udev.extraRules = ''
    # YubiKey CCID (smart card interface for GPG)
    ACTION=="add|change", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", GROUP="plugdev", MODE="0660"
    # YubiKey HID (for OTP, FIDO, etc.)
    ACTION=="add|change", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", GROUP="plugdev", MODE="0660"
  '';
}
