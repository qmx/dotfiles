{
  description = "qmx's Nix Darwin Configuration";

  inputs = {
    core.url = "git+file:../core.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { core, nixpkgs, home-manager, nix-darwin, ... }:
  let
    username = "qmx";
    homeDirectory = "/Users/${username}";
    system = "aarch64-darwin";

    pkgs = import nixpkgs (
      import ./nixpkgs.nix {
        inherit system;
      }
    );
  in
  {
    # Build darwin flake using:
    # $ sudo darwin-rebuild switch --flake .
    darwinConfigurations."meduseld" = nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      modules = [
        core.nix-darwin
        ./modules/nix-darwin
        ./hosts/meduseld/nix-darwin
      ];
      specialArgs = { inherit username; };
    };

    # Build home-manager using:
    # $ home-manager switch --flake .
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        core.home-manager
        ./modules/home-manager
        ./hosts/meduseld/home-manager
      ];
      extraSpecialArgs = { inherit username homeDirectory; };
    };

    # Development shell with useful commands
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        home-manager.packages.${system}.home-manager
        nix-darwin.packages.${system}.darwin-rebuild
      ];
      shellHook = ''
        echo "Commands:"
        echo "  sudo darwin-rebuild switch --flake ."
        echo "  home-manager switch --flake ."
        echo "  home-manager news --flake ."
        echo "  nix flake update"
        echo "  nix flake lock --update-input core"
      '';
    };
  };
}
