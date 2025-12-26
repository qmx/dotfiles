{
  username,
  homeDirectory,
  ...
}:

let
  repoRoot = ../../..;
in
{
  # erebor - Attic binary cache VM

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };

  # Secrets management for attic token
  secrets = {
    enable = true;
    encrypted = "${repoRoot}/secrets/secrets.json.age";
    envFile = "${homeDirectory}/.secrets/env";
    templates.env = {
      template = "${repoRoot}/templates/env.j2";
      output = "${homeDirectory}/.secrets/env";
    };
  };

  # Attic client for local pushes
  programs.attic-client = {
    enable = true;
    endpoint = "http://localhost:8080";
  };
}
