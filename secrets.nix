let
  home = builtins.getEnv "HOME";
  secretsPath = "${home}/.config/nix/secrets.json";
  tryReadSecrets = builtins.tryEval (builtins.fromJSON (builtins.readFile secretsPath));
in
if tryReadSecrets.success then
  tryReadSecrets.value
else
  builtins.trace
    "WARNING: secrets.json is encrypted or unavailable at ${secretsPath}. Run 'git-crypt unlock' to decrypt."
    {
      braveApiKey = "";
      orthancUrl = "http://localhost:8080";
      homebridge = {
        bridge = {
          pin = "";
          username = "";
        };
        cameras = [ ];
      };
    }
