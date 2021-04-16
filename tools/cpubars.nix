{ rustPlatform, lib, stdenv, darwin, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "cpubars";
  version = "0.5.0";

  src = fetchCrate {
    inherit pname;
    inherit version;
    sha256 = "0mfdcdycnbiwn70n5qhrxzax8ms3fziblzczy8g56qbdlrbfflsg";
  };

  cargoSha256 = "05zbcx6zvnw3s0xa2fq3indl2y4n2c62z91dddwzpgjya8ay6703";

  doCheck = false;
}
