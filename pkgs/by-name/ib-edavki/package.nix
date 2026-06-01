{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonPackage {
  pname = "ib_edavki";
  version = "unstable-2026-01-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jamsix";
    repo = "ib-edavki";
    rev = "f0e9f29e19bf419852be2ae7b8a28311e3260821";
    hash = "sha256-JVNxSgH2sCaaquZpckh3NjZq466wBpfmnXoSxseEq8Y=";
  };

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    requests
    certifi
  ];

  pythonImportsCheck = [ "ib_edavki" ];

  meta = {
    description = "Convert InteractiveBrokers XML reports to Slovenian tax forms (Doh-KDVP, D-IFI, D-Div, Doh-Obr)";
    homepage = "https://github.com/jamsix/ib-edavki";
    mainProgram = "ib_edavki";
    license = lib.licenses.mit;
  };
}
