{
  username,
  homeDirectory,
  ...
}:
let
  repoRoot = ../../..;
in
{
  # wk3 - Linux workstation cluster node (Raspberry Pi, Debian-based)

  imports = [
    ../../../roles/linux-yubikey/home-manager
    ./homebridge.nix
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.11";
  };

  # Secrets management with age + minijinja
  secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
    envFile = "${homeDirectory}/.secrets/env";
    templates = {
      env = {
        template = "${repoRoot}/templates/env.j2";
        output = "${homeDirectory}/.secrets/env";
      };
      homebridge = {
        template = "${repoRoot}/templates/homebridge.json.j2";
        output = "${homeDirectory}/.homebridge/config.json";
        mode = "0600";
      };
    };
  };
}
