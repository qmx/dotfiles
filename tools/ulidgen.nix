{ rustPlatform, lib, stdenv, darwin, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "ulidgen";
  version = "0.1.0";

  src = fetchCrate {
    inherit pname;
    version = "0.1.0";
    sha256 = "0441sx02hq5nf2jldnhb304rya0gfsvv43665bnfdbxjfh7iwpq7";
  };

  cargoSha256 = "1wjzxjicclny7r5vwhzq7scphrfi9lapdvxysbm5yr7jl274y4ry";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Foundation
  ];

  doCheck = false;
}
