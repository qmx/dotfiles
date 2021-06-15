{ rustPlatform, lib, stdenv, darwin, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "ulidgen";
  version = "0.1.0";

  src = fetchCrate {
    inherit pname;
    version = "0.1.0";
    sha256 = "0441sx02hq5nf2jldnhb304rya0gfsvv43665bnfdbxjfh7iwpq7";
  };

  cargoSha256 = "195krg74z17n0j4rwmrv2w5swsnim7j53xpnbmy6mmq2bwcqqidi";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Foundation
  ];

  doCheck = false;
}
