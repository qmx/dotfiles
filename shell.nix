let

  nixpkgs = builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixos-unstable-2021-10-07";
    url = "https://github.com/nixos/nixpkgs/archive/5e2018f7b383aeca6824a30c0cd1978c9532a46a.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1i4ak2qb1q9rign398ycr190qv5ckc9inl24gf00070ykymzjs00";
  };

  home-manager = builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "home-manager-master-2021-10-07";
    url = "https://github.com/nix-community/home-manager/archive/49695f33aac22358b59e49c94fe6472218e5d766.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1kb4hx8ymdynfz08c417wvql7yq07w5sabxhihlvlfnzicnrbsp7";
  };

  pkgs = import nixpkgs {};

in
pkgs.mkShell rec {
  name = "home-manager-shell";

  buildInputs = with pkgs; [
    (import home-manager { inherit pkgs; }).home-manager
  ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs}:home-manager=${home-manager}"
  '';

}
