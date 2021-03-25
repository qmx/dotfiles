{ writeScriptBin, pkgs }:
with pkgs;
writeScriptBin "nrails" ''
  if [ -z "$1" ]; then
    echo "Usage: nrails APP_NAME"
    exit 1
  fi

  APP_NAME="$1"
  TARGET=`${mktemp}/bin/mktemp -d`
  APP_DIR="$PWD"
  (
  cd $TARGET
  ${niv}/bin/niv init -b nixpkgs-unstable

  cat <<EOS >Gemfile
  source 'https://rubygems.org'
  gem 'rails', '6.1'
  EOS

  cat <<EOS >bundler.nix
  let
    sources = import ./nix/sources.nix;
    nixpkgs = sources."nixpkgs";
  in
    with (import nixpkgs {});
  let
    myBundler = bundler.override { ruby = ruby_2_7; };
  in
    mkShell {
      name = "bundler-shell";
      buildInputs = [ myBundler bundix ];
    }
  EOS

  nix-shell --run "bundle lock" bundler.nix

  cat <<EOS >shell.nix
  let
    sources = import ./nix/sources.nix;
    nixpkgs = sources."nixpkgs";
  in
    with (import nixpkgs {});
  let
    env = bundlerEnv {
      name = "$APP_NAME";
      ruby = ruby_2_7;
      gemdir = ./.;
    };
  in mkShell { buildInputs = [ env env.wrappedRuby ]; }
  EOS

  rm -f gemset.nix
  nix-shell -p bundix --run "bundix"
  nix-shell --run "rails new --api -d postgresql $APP_DIR/$APP_NAME"
  )
  (
  cd $APP_NAME
  ${niv}/bin/niv init -b nixpkgs-unstable

  cat <<EOS >bundler.nix
  let
    sources = import ./nix/sources.nix;
    nixpkgs = sources."nixpkgs";
  in
    with (import nixpkgs {});
  let
    myBundler = bundler.override { ruby = ruby_2_7; };
  in
    mkShell {
      name = "bundler-shell";
      buildInputs = [ myBundler bundix ];
    }
  EOS

  nix-shell --run "bundle lock" bundler.nix

  cat <<EOS >shell.nix
  let
    sources = import ./nix/sources.nix;
    nixpkgs = sources."nixpkgs";
  in
    with (import nixpkgs {});
  let
    env = bundlerEnv {
      name = "$APP_NAME";
      ruby = ruby_2_7;
      gemdir = ./.;
    };
  in mkShell { buildInputs = [ env env.wrappedRuby postgresql_12 libiconv zlib ]; }
  EOS

  rm -f gemset.nix
  nix-shell -p bundix --run "bundix"

  cat <<EOS >.envrc
  #!/bin/sh
  use_nix

  export PGHOST=$PWD/tmp/postgres
  echo "you can start the database with 'local_pg start'"
  EOS

  nix-shell --run "rails  -v"
  )
''

