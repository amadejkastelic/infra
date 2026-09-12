{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-plugins-official";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "3deb821cb71ccfaaf2ffa9935e977df314ce5cd5";
    hash = "sha256-8LgDacLKv4gLPYrgIwg/O8IfySBwa/AxgrLXFdliROc=";
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
