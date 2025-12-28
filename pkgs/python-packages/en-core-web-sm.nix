{
  lib,
  buildPythonPackage,
  fetchurl,
  spacy,
}:

buildPythonPackage rec {
  pname = "en_core_web_sm";
  version = "3.8.0";
  format = "wheel";

  src = fetchurl {
    url = "https://github.com/explosion/spacy-models/releases/download/${pname}-${version}/${pname}-${version}-py3-none-any.whl";
    hash = "sha256-GTJCnbcn1L/z3u1rNM/AXfF3lPSlLusmz4ko98Gg+4U=";
  };

  dependencies = [ spacy ];

  # No tests for data-only package
  doCheck = false;

  pythonImportsCheck = [ "en_core_web_sm" ];

  meta = {
    description = "English pipeline optimized for CPU (small)";
    homepage = "https://spacy.io/models/en#en_core_web_sm";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
