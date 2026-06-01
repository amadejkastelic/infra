{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:
stdenv.mkDerivation rec {
  pname = "sekirofpsunlock";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "Lahvuun";
    repo = "sekirofpsunlock";
    rev = "v${version}";
    hash = "sha256-tdKm7VNlOQST2uIXTajD7BCbhLktNRysOuDSYd9ONEU=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 sekirofpsunlock -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Linux patcher for Sekiro that removes FPS and resolution limitations";
    homepage = "https://github.com/Lahvuun/sekirofpsunlock";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sekirofpsunlock";
  };
}
