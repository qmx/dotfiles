{
  description = "qmx's Nix Configuration";

  inputs = {
    core.url = "github:qmx/core.nix";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    opencode = {
      url = "github:sst/opencode/v1.0.169";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    try = {
      url = "github:qmx/try/fix-flake-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    duckduckgo-mcp-server = {
      url = "github:qmx/duckduckgo-mcp-server/nix";
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
      nixos-hardware,
      try,
      duckduckgo-mcp-server,
      ...
    }:
    let
      username = "qmx";
      homeDirectory = "/Users/${username}";
      system = "aarch64-darwin";

      # Model catalog library
      modelsLib = import ./lib { lib = nixpkgs-unstable.lib; };

      # Import pkgs-stable directly (pkgs comes from nixpkgs.nix with overlays)
      pkgs-stable = import nixpkgs-stable { inherit system; };

      # Use dotfiles' nixpkgs.nix for pkgs (includes overlays)
      pkgs = import nixpkgs-unstable (import ./nixpkgs.nix { inherit system; });

      # Helper to create bump-opencode script for any pkgs
      mkBumpOpencode =
        p:
        p.writeShellScriptBin "bump-opencode" ''
          LATEST=$(${p.curl}/bin/curl -s https://api.github.com/repos/sst/opencode/releases/latest | ${p.jq}/bin/jq -r .tag_name)
          echo "Latest opencode: $LATEST"
          echo "Update flake.nix line 18: url = \"github:sst/opencode/$LATEST\""
          echo "Then run: nix flake update opencode"
        '';

      # Helper to create extraSpecialArgs for any system
      mkExtraSpecialArgs =
        targetSystem:
        let
          isDarwin = builtins.match ".*-darwin" targetSystem != null;
          targetPkgsStable = import nixpkgs-stable { system = targetSystem; };
        in
        {
          inherit username modelsLib;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
          pkgs-stable = targetPkgsStable;
          opencode = opencode.packages.${targetSystem}.default;
          beads = beads.packages.${targetSystem}.default;
          beadsSkill = "${beads}/skills/beads";
          duckduckgo-mcp-server = duckduckgo-mcp-server.packages.${targetSystem}.default;
        };

      # Helper for aarch64-linux home-manager configurations (wk3, k01)
      mkLinuxHome =
        hostname:
        let
          linuxSystem = "aarch64-linux";
          linuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = linuxSystem; });
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          modules = [
            core.home-manager
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
            ./hosts/${hostname}/home-manager
          ];
          extraSpecialArgs = mkExtraSpecialArgs linuxSystem;
        };

      # Helper for x86_64-linux home-manager configurations (orthanc)
      mkX86LinuxHome =
        hostname:
        let
          x86LinuxSystem = "x86_64-linux";
          x86LinuxPkgs = import nixpkgs-unstable (import ./nixpkgs.nix { system = x86LinuxSystem; });
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = x86LinuxPkgs;
          modules = [
            core.home-manager
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
            ./hosts/${hostname}/home-manager
          ];
          extraSpecialArgs = mkExtraSpecialArgs x86LinuxSystem;
        };

      linuxHosts = [
        "wk3"
        "k01"
      ];
      x86LinuxHosts = [ "orthanc" ];

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
            (mkBumpOpencode targetPkgs)
          ]
          ++ nixpkgs-unstable.lib.optionals isDarwin [
            nix-darwin.packages.${targetSystem}.darwin-rebuild
          ];

          shellHook = ''
            eval "$(starship init bash)"

            ${nixpkgs-unstable.lib.optionalString (!isDarwin) ''
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
      nixosConfigurations."orthanc" = nixpkgs-nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series
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
            try.homeModules.default
            ./modules/secrets
            ./modules/home-manager
            ./hosts/meduseld/home-manager
          ];
          extraSpecialArgs = mkExtraSpecialArgs system;
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

      # Development shells for all platforms
      devShells = {
        ${system}.default = mkDevShell system;
        "aarch64-linux".default = mkDevShell "aarch64-linux";
        "x86_64-linux".default = mkDevShell "x86_64-linux";
      };
    };
}
