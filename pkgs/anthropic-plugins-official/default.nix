{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-plugins-official";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "315c4e48967d9541c29c3c656441dded353ca7aa";
    hash = "sha256-uVtG87hx2ksdrsq2cI7o5F6cycMTXNnmluHTUmcjVO8=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta.description = "Anthropic's official Claude plugin marketplace repository";
})
