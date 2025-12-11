{
  description = "qmx's Nix Configuration";

  inputs = {
    core.url = "github:qmx/core.nix";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/5ae3b07d8d6527c42f17c876e404993199144b6a";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    opencode = {
      url = "github:sst/opencode/v1.0.144";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      core,
      nixpkgs-unstable,
      nixpkgs-stable,
      nixpkgs-nixos,
      home-manager,
      nix-darwin,
      opencode,
      beads,
      ...
    }:
    let
      username = "qmx";
      homeDirectory = "/Users/${username}";
      system = "aarch64-darwin";

      # Model catalog library
      llamaLib = import ./lib { lib = nixpkgs-unstable.lib; };

      # Import pkgs-stable directly (pkgs comes from nixpkgs.nix with overlays)
      pkgs-stable = import nixpkgs-stable { inherit system; };

      # Use dotfiles' nixpkgs.nix for pkgs (includes overlays)
      pkgs = import nixpkgs-unstable (import ./nixpkgs.nix { inherit system; });

      # Load secrets from secrets.nix
      secrets = import ./secrets.nix;

      # Helper to create bump-opencode script for any pkgs
      mkBumpOpencode =
        p:
        p.writeShellScriptBin "bump-opencode" ''
          LATEST=$(${p.curl}/bin/curl -s https://api.github.com/repos/sst/opencode/releases/latest | ${p.jq}/bin/jq -r .tag_name)
          echo "Latest opencode: $LATEST"
          echo "Update flake.nix line 18: url = \"github:sst/opencode/$LATEST\""
          echo "Then run: nix flake update opencode"
        '';

      # Helper for aarch64-linux home-manager configurations (wk3, k01)
      mkLinuxHome =
        hostname:
        let
          linuxSystem = "aarch64-linux";
          linuxPkgsStable = import nixpkgs-stable { system = linuxSystem; };
          linuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = linuxSystem; });
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
            pkgs-stable = linuxPkgsStable;
            secrets = secrets;
            opencode = opencode.packages.${linuxSystem}.default;
            beads = beads.packages.${linuxSystem}.default;
            inherit llamaLib;
          };
        };

      # Helper for x86_64-linux home-manager configurations (orthanc)
      mkX86LinuxHome =
        hostname:
        let
          x86LinuxSystem = "x86_64-linux";
          x86LinuxPkgsStable = import nixpkgs-stable { system = x86LinuxSystem; };
          x86LinuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = x86LinuxSystem; });
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = x86LinuxPkgs;
          modules = [
            core.home-manager
            ./modules/home-manager
            ./hosts/${hostname}/home-manager
          ];
          extraSpecialArgs = {
            username = username;
            homeDirectory = "/home/${username}";
            pkgs-stable = x86LinuxPkgsStable;
            secrets = secrets;
            opencode = opencode.packages.${x86LinuxSystem}.default;
            beads = beads.packages.${x86LinuxSystem}.default;
            inherit llamaLib;
          };
        };

      linuxHosts = [
        "wk3"
        "k01"
      ];
      x86LinuxHosts = [ "orthanc" ];
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

      # Build NixOS using:
      # $ sudo nixos-rebuild switch --flake .#orthanc
      nixosConfigurations."orthanc" = nixpkgs-nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/orthanc/nixos
        ];
        specialArgs = { inherit username; };
      };

      # Build home-manager using:
      # $ home-manager switch --flake .              (macOS)
      # $ home-manager switch --flake .#qmx@wk3      (Linux aarch64)
      # $ home-manager switch --flake .#qmx@k01      (Linux aarch64)
      # $ home-manager switch --flake .#qmx@orthanc  (Linux x86_64)
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
            inherit
              username
              homeDirectory
              llamaLib
              secrets
              ;
            inherit pkgs-stable;
            opencode = opencode.packages.${system}.default;
            beads = beads.packages.${system}.default;
          };
        };
      }
      // builtins.listToAttrs (
        map (hostname: {
          name = "${username}@${hostname}";
          value = mkLinuxHome hostname;
        }) linuxHosts
      )
      // builtins.listToAttrs (
        map (hostname: {
          name = "${username}@${hostname}";
          value = mkX86LinuxHome hostname;
        }) x86LinuxHosts
      );

      # Formatter for `nix fmt`
      formatter = {
        ${system} = pkgs.nixfmt-tree;
        "aarch64-linux" =
          (import nixpkgs-unstable (import ./nixpkgs.nix { system = "aarch64-linux"; })).nixfmt-tree;
        "x86_64-linux" =
          (import nixpkgs-unstable (import ./nixpkgs.nix { system = "x86_64-linux"; })).nixfmt-tree;
      };

      # Development shell with useful commands (macOS)
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          home-manager.packages.${system}.home-manager
          nix-darwin.packages.${system}.darwin-rebuild
          pkgs-stable.starship
          pkgs.nixfmt-rfc-style
          (mkBumpOpencode pkgs)
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

      # Development shell for Linux aarch64 (wk3, k01)
      devShells."aarch64-linux".default =
        let
          linuxPkgsStable = import nixpkgs-stable { system = "aarch64-linux"; };
          linuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = "aarch64-linux"; });
        in
        linuxPkgs.mkShell {
          buildInputs = [
            home-manager.packages."aarch64-linux".home-manager
            linuxPkgsStable.starship
            linuxPkgs.git-crypt
            linuxPkgs.nixfmt-rfc-style
            (mkBumpOpencode linuxPkgs)
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

      # Development shell for Linux x86_64 (orthanc)
      devShells."x86_64-linux".default =
        let
          x86LinuxPkgsStable = import nixpkgs-stable { system = "x86_64-linux"; };
          x86LinuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = "x86_64-linux"; });
        in
        x86LinuxPkgs.mkShell {
          buildInputs = [
            home-manager.packages."x86_64-linux".home-manager
            x86LinuxPkgsStable.starship
            x86LinuxPkgs.git-crypt
            x86LinuxPkgs.nixfmt-rfc-style
            (mkBumpOpencode x86LinuxPkgs)
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
            echo "  sudo nixos-rebuild switch --flake .#orthanc"
            echo "  home-manager switch --flake .#qmx@orthanc"
            echo "  home-manager news --flake .#qmx@orthanc"
            echo "  nix flake update"
            echo "  nix flake update core"
          '';
        };
    };
}
