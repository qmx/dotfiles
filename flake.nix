{
  description = "qmx's Nix Darwin Configuration";

  inputs = {
    core.url = "github:qmx/core.nix";
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

    # Get pkgs-stable from core.nix helper
    corePkgs = core.lib.mkPkgs system;

    # Use dotfiles' nixpkgs.nix for pkgs (includes overlays)
    pkgs = import nixpkgs (import ./nixpkgs.nix { inherit system; });

    # Load secrets from secrets.nix
    secrets = import ./secrets.nix;

    # Helper for Linux home-manager configurations
    mkLinuxHome = hostname:
      let
        linuxCorePkgs = core.lib.mkPkgs "aarch64-linux";
        linuxPkgs = import nixpkgs (
          import ./nixpkgs.nix { system = "aarch64-linux"; }
        );
      in
      home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        modules = [
          core.home-manager
          ./modules/home-manager
          ./hosts/${hostname}/home-manager
        ];
        extraSpecialArgs = {
          username = username;
          homeDirectory = "/home/${username}";
          pkgs-stable = linuxCorePkgs.pkgs-stable;
          secrets = secrets;
        };
      };

    linuxHosts = [ "wk3" "k01" ];
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
    # $ home-manager switch --flake .              (macOS)
    # $ home-manager switch --flake .#qmx@wk3      (Linux)
    # $ home-manager switch --flake .#qmx@k01      (Linux)
    homeConfigurations = {
      # macOS (meduseld)
      ${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          core.home-manager
          ./modules/home-manager
          ./hosts/meduseld/home-manager
        ];
        extraSpecialArgs = {
          inherit username homeDirectory;
          pkgs-stable = corePkgs.pkgs-stable;
        };
      };
    } // builtins.listToAttrs (
      map (hostname: {
        name = "${username}@${hostname}";
        value = mkLinuxHome hostname;
      }) linuxHosts
    );

    # Development shell with useful commands (macOS)
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        home-manager.packages.${system}.home-manager
        nix-darwin.packages.${system}.darwin-rebuild
        corePkgs.pkgs-stable.starship
      ];
      shellHook = ''
        eval "$(starship init bash)"

        echo "Commands:"
        echo "  sudo darwin-rebuild switch --flake ."
        echo "  home-manager switch --flake ."
        echo "  home-manager news --flake ."
        echo "  nix flake update"
        echo "  nix flake update core"
      '';
    };

    # Development shell for Linux (wk3)
    devShells."aarch64-linux".default = let
      linuxCorePkgs = core.lib.mkPkgs "aarch64-linux";
      linuxPkgs = import nixpkgs (
        import ./nixpkgs.nix { system = "aarch64-linux"; }
      );
    in linuxPkgs.mkShell {
      buildInputs = [
        home-manager.packages."aarch64-linux".home-manager
        linuxCorePkgs.pkgs-stable.starship
        linuxPkgs.git-crypt
      ];
      shellHook = ''
        eval "$(starship init bash)"

        # YubiKey udev rules check (Linux only)
        if [ ! -f /etc/udev/rules.d/70-yubikey-usb.rules ]; then
          echo ""
          echo "⚠️  YubiKey SSH Access Not Configured"
          echo ""
          echo "YubiKey needs GROUP-based udev rules for SSH sessions."
          echo "After running 'home-manager switch', install the rules once:"
          echo ""
          echo "  sudo cp ~/.config/yubikey-udev/70-yubikey-usb.rules /etc/udev/rules.d/"
          echo "  sudo udevadm control --reload-rules && sudo udevadm trigger"
          echo ""
          echo "Then unplug and replug your YubiKey."
          echo ""
        fi

        echo "Commands:"
        echo "  home-manager switch --flake ."
        echo "  home-manager news --flake ."
        echo "  nix flake update"
        echo "  nix flake update core"
      '';
    };
  };
}
