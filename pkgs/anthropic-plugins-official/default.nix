{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-plugins-official";
  version = "0-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "af59ee3a1051a29dda4a2e7a2af221aa457ae08b";
    hash = "sha256-I7Ko4Ssksx6mkhej73jihZ3cuHuS7qePfBwpUebwttI=";
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
