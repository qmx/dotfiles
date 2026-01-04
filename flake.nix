{
  description = "qmx's Nix Configuration";

  inputs = {
    core.url = "github:qmx/core.nix";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    opencode = {
      url = "github:anomalyco/opencode/v1.0.223";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    beads = {
      url = "github:steveyegge/beads/v0.43.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    budgie = {
      url = "github:qmx/budgie";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    try = {
      url = "github:qmx/try/dev";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    duckduckgo-mcp-server = {
      url = "github:qmx/duckduckgo-mcp-server/nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
    jellarr = {
      url = "github:venkyr77/jellarr";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
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
      budgie,
      nixos-hardware,
      try,
      duckduckgo-mcp-server,
      nixos-generators,
      jellarr,
      ...
    }:
    let
      username = "qmx";
      homeDirectory = "/Users/${username}";
      system = "aarch64-darwin";

      # Model catalog library
      modelsLib = import ./lib { lib = nixpkgs-unstable.lib; };

      # Import pkgs-stable with same config/overlays as pkgs
      pkgs-stable = import nixpkgs-stable (import ./nixpkgs.nix { inherit system; });

      # Use dotfiles' nixpkgs.nix for pkgs (includes overlays)
      pkgs = import nixpkgs-unstable (import ./nixpkgs.nix { inherit system; });

      # Helper to create bump script for checking package versions
      mkBump =
        p:
        p.writeShellScriptBin "bump" ''
          set -euo pipefail

          CURL="${p.curl}/bin/curl"
          JQ="${p.jq}/bin/jq"

          # Current versions (edit these when updating)
          OPENCODE_VERSION="v1.0.223"
          LLAMA_CPP_VERSION="7616"
          LLAMA_SWAP_VERSION="182"
          BEADS_VERSION="v0.43.0"

          check_opencode() {
            local latest current="$OPENCODE_VERSION"
            latest=$($CURL -sL "https://api.github.com/repos/anomalyco/opencode/releases/latest" | $JQ -r .tag_name)

            if [[ $current == "$latest" ]]; then
              echo "opencode: $current (up to date)"
            else
              echo "opencode: $current -> $latest"
              echo "  Update flake.nix: url = \"github:anomalyco/opencode/$latest\""
              echo "  Update this script: OPENCODE_VERSION=\"$latest\""
              echo "  Then run: nix flake update opencode"
            fi
          }

          check_llama_cpp() {
            local latest current="$LLAMA_CPP_VERSION"
            latest=$($CURL -sL "https://api.github.com/repos/ggerganov/llama.cpp/releases/latest" | $JQ -r .tag_name)
            local latest_num=''${latest#b}

            if [[ $current == "$latest_num" ]]; then
              echo "llama-cpp: $current (up to date)"
            else
              echo "llama-cpp: $current -> $latest"
              echo "  Update pkgs/default.nix: version = \"$latest_num\""
              echo "  Update this script: LLAMA_CPP_VERSION=\"$latest_num\""
              echo "  Then run: nix-prefetch-github ggerganov llama.cpp --rev $latest"
            fi
          }

          check_llama_swap() {
            local latest current="$LLAMA_SWAP_VERSION"
            latest=$($CURL -sL "https://api.github.com/repos/mostlygeek/llama-swap/releases/latest" | $JQ -r .tag_name)
            local latest_num=''${latest#v}

            if [[ $current == "$latest_num" ]]; then
              echo "llama-swap: $current (up to date)"
            else
              echo "llama-swap: $current -> $latest"
              echo "  Update pkgs/llama-swap/default.nix: version = \"$latest_num\""
              echo "  Update this script: LLAMA_SWAP_VERSION=\"$latest_num\""
              echo "  Then run: nix-prefetch-github mostlygeek llama-swap --rev $latest"
            fi
          }

          check_beads() {
            local latest current="$BEADS_VERSION"
            latest=$($CURL -sL "https://api.github.com/repos/steveyegge/beads/releases/latest" | $JQ -r .tag_name)

            if [[ $current == "$latest" ]]; then
              echo "beads: $current (up to date)"
            else
              echo "beads: $current -> $latest"
              echo "  Update flake.nix: url = \"github:steveyegge/beads/$latest\""
              echo "  Update this script: BEADS_VERSION=\"$latest\""
              echo "  Then run: nix flake update beads"
            fi
          }

          case "''${1:-all}" in
            all)
              check_opencode
              check_llama_cpp
              check_llama_swap
              check_beads
              ;;
            opencode) check_opencode ;;
            llama-cpp) check_llama_cpp ;;
            llama-swap) check_llama_swap ;;
            beads) check_beads ;;
            *)
              echo "Unknown package: $1"
              echo "Available: opencode llama-cpp llama-swap beads"
              exit 1
              ;;
          esac
        '';

      # Helper to create extraSpecialArgs for any system
      mkExtraSpecialArgs =
        targetSystem:
        let
          isDarwin = builtins.match ".*-darwin" targetSystem != null;
          targetPkgsStable = import nixpkgs-stable { system = targetSystem; };
          targetPkgsUnstable = import nixpkgs-unstable {
            system = targetSystem;
            config.allowUnfree = true;
          };
        in
        {
          inherit username modelsLib;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
          pkgs-stable = targetPkgsStable;
          pkgs-unstable = targetPkgsUnstable;
          opencode = opencode.packages.${targetSystem}.default;
          beads = beads.packages.${targetSystem}.default;
          beadsSkill = "${beads}/skills/beads";
          budgie = budgie.packages.${targetSystem}.default;
          duckduckgo-mcp-server = duckduckgo-mcp-server.packages.${targetSystem}.default;
        };

      # Helper for Linux home-manager configurations
      mkLinuxHome =
        hostname: system: extraModules:
        let
          linuxPkgs = import nixpkgs-stable (import ./nixpkgs.nix { inherit system; });
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          modules = [
            core.home-manager
            ./hosts/${hostname}/home-manager
          ]
          ++ extraModules;
          extraSpecialArgs = mkExtraSpecialArgs system;
        };

      # Linux hosts: hostname -> { system, modules }
      linuxHosts = {
        wk3 = {
          system = "aarch64-linux";
          modules = [
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
          ];
        };
        sirannon = {
          system = "aarch64-linux";
          modules = [ ];
        };
        orthanc = {
          system = "x86_64-linux";
          modules = [
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
          ];
        };
        imladris = {
          system = "x86_64-linux";
          modules = [ ];
        };
      };

      # Helper to create QCOW2 VM images with home-manager baked in
      mkVMImage =
        {
          hostname,
          diskSize ? 32 * 1024,
        }:
        let
          targetSystem = "x86_64-linux";
          targetPkgsStable = import nixpkgs-stable { system = targetSystem; };
          targetPkgsUnstable = import nixpkgs-unstable {
            system = targetSystem;
            config.allowUnfree = true;
          };
        in
        nixos-generators.nixosGenerate {
          system = targetSystem;
          format = "qcow-efi";
          modules = [
            ./hosts/${hostname}/nixos
            ./hosts/${hostname}/nixos/image-home-manager.nix
            {
              virtualisation.diskSize = diskSize;
              nixpkgs.config.allowUnfree = true;
            }
          ];
          specialArgs = {
            inherit
              username
              home-manager
              core
              modelsLib
              ;
            homeDirectory = "/home/${username}";
            pkgs-stable = targetPkgsStable;
            pkgs-unstable = targetPkgsUnstable;
            opencode = opencode.packages.${targetSystem}.default;
            beads = beads.packages.${targetSystem}.default;
            beadsSkill = "${beads.packages.${targetSystem}.default}/skills/beads";
            duckduckgo-mcp-server = duckduckgo-mcp-server.packages.${targetSystem}.default;
          };
        };

      # Helper to create nixify-model script
      mkNixifyModel =
        p:
        p.writeShellScriptBin "nixify-model" ''
          export PATH="${p.zstd}/bin:$PATH"
          exec ${./scripts/nixify-model} "$@"
        '';

      # Helper to create devShell for any system
      mkDevShell =
        targetSystem:
        let
          isDarwin = builtins.match ".*-darwin" targetSystem != null;
          targetPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = targetSystem; });
          targetPkgsStable = import nixpkgs-stable { system = targetSystem; };
        in
        targetPkgs.mkShell {
          buildInputs = [
            home-manager.packages.${targetSystem}.home-manager
            targetPkgsStable.starship
            targetPkgs.nixfmt-rfc-style
            targetPkgs.age
            targetPkgs.nix-prefetch-github
            (mkBump targetPkgs)
            (mkNixifyModel targetPkgs)
          ]
          ++ nixpkgs-unstable.lib.optionals isDarwin [
            nix-darwin.packages.${targetSystem}.darwin-rebuild
          ];

          shellHook = ''
            eval "$(starship init bash)"

            ${nixpkgs-unstable.lib.optionalString (!isDarwin) ''
              # YubiKey udev rules check (non-NixOS Linux only)
              # On NixOS, udev rules are managed declaratively via modules/nixos/yubikey.nix
              if [ ! -f /etc/udev/rules.d/70-yubikey-usb.rules ] && [ ! -f /etc/NIXOS ]; then
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
            ''}
            echo "Commands:"
            ${nixpkgs-unstable.lib.optionalString isDarwin ''
              echo "  sudo darwin-rebuild switch --flake ."
            ''}
            echo "  home-manager switch --flake ."
            echo "  home-manager news --flake ."
            echo "  nix flake update"
            echo "  nix flake update core"
          '';
        };
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
      # $ sudo nixos-rebuild switch --flake .#sirannon
      nixosConfigurations."orthanc" = nixpkgs-nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series
          ./hosts/orthanc/nixos
        ];
        specialArgs = { inherit username; };
      };

      nixosConfigurations."sirannon" = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/sirannon/nixos
        ];
        specialArgs = { inherit username; };
      };

      nixosConfigurations."imladris" = nixpkgs-nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          jellarr.nixosModules.default
          ./hosts/imladris/nixos
        ];
        specialArgs = { inherit username; };
      };

      # Build home-manager using:
      # $ home-manager switch --flake .              (macOS)
      # $ home-manager switch --flake .#qmx@wk3      (Linux aarch64)
      # $ home-manager switch --flake .#qmx@sirannon (Linux aarch64, barebones)
      # $ home-manager switch --flake .#qmx@orthanc  (Linux x86_64)
      # $ home-manager switch --flake .#qmx@imladris (Linux x86_64)
      homeConfigurations = {
        # macOS (meduseld)
        ${username} = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-stable;
          modules = [
            core.home-manager
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
            ./hosts/meduseld/home-manager
          ];
          extraSpecialArgs = mkExtraSpecialArgs system;
        };
      }
      // nixpkgs-unstable.lib.mapAttrs' (hostname: cfg: {
        name = "${username}@${hostname}";
        value = mkLinuxHome hostname cfg.system cfg.modules;
      }) linuxHosts;

      # Formatter for `nix fmt`
      formatter = {
        ${system} = pkgs.nixfmt-tree;
        "aarch64-linux" =
          (import nixpkgs-unstable (import ./nixpkgs.nix { system = "aarch64-linux"; })).nixfmt-tree;
        "x86_64-linux" =
          (import nixpkgs-unstable (import ./nixpkgs.nix { system = "x86_64-linux"; })).nixfmt-tree;
      };

      # Development shells for all platforms
      devShells = {
        ${system}.default = mkDevShell system;
        "aarch64-linux".default = mkDevShell "aarch64-linux";
        "x86_64-linux".default = mkDevShell "x86_64-linux";
      };

      # VM images
      # To create a new VM, copy hosts/base-vm/ to hosts/<new-hostname>/,
      # update networking.hostName, then run: nix build .#<new-hostname>-qcow2
      # After first boot, add to nixosConfigurations for ongoing management.
      packages."x86_64-linux" =
        let
          x86Pkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = "x86_64-linux"; });
        in
        {
          base-vm-qcow2 = mkVMImage { hostname = "base-vm"; };

          # Docker Compose configs for Synology nix cache
          ark-nixcache =
            let
              base = import ./hosts/ark/docker { pkgs = x86Pkgs; };
            in
            x86Pkgs.runCommand "ark-nixcache" { } ''
              mkdir -p $out
              cp -r ${base}/* $out/
              cp ${./templates/ark-docker-compose.yml.j2} $out/docker-compose.yml.j2
            '';
        };
    };
}
