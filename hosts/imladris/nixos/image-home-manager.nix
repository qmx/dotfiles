# Only used for image generation - bakes home-manager into the initial image
{
  username,
  homeDirectory,
  home-manager,
  core,
  pkgs-stable,
  pkgs-unstable,
  modelsLib,
  opencode,
  sterna,
  duckduckgo-mcp-server,
  ...
}:

{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      imports = [
        core.home-manager
        ../home-manager
      ];
      home.stateVersion = "25.05";
    };
    extraSpecialArgs = {
      inherit
        username
        homeDirectory
        pkgs-stable
        pkgs-unstable
        modelsLib
        opencode
        sterna
        duckduckgo-mcp-server
        ;
    };
  };
}
