{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "perles";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "zjrosen";
    repo = "perles";
    rev = "v${version}";
    hash = "sha256-lClYLsh4pjFca9ED7ZTi1XMyCsHN2HgQMyR3BQ4j55A=";
  };

  vendorHash = "sha256-yLpQlubOVl7JrLT8o8B++jKiCufK6G7Qss5znHdUzeQ=";

  doCheck = false;

  meta = {
    description = "Terminal kanban board for beads issue tracker";
    homepage = "https://github.com/zjrosen/perles";
    license = lib.licenses.mit;
    mainProgram = "perles";
  };
}
