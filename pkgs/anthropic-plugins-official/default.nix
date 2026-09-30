{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-plugins-official";
  version = "0-unstable-2026-09-29";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "2a8ad9f74633d10e3d9bb0660a03bfc6e50584b1";
    hash = "sha256-JNUkda+v5LD9wDCg/R4c4zh5vACzBaxv6iIyZYYmvh0=";
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
