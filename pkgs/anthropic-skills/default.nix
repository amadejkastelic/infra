{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anthropic-skills";
  version = "0-unstable-2026-09-24";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "33375500bcea98d610eb30ce10ac4e59b89c390d";
    hash = "sha256-xUs7UX8pOcZwR0okaSbI/f8EE5F4Zi/BUd+nIZNafPc=";
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

  meta.description = "Anthropic's official Claude skills repository";
})
