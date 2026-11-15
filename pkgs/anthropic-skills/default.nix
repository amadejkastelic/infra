{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anthropic-skills";
  version = "0-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "1780c5e5a552fd4d1c9d6a7b0cab26b0c2bef064";
    hash = "sha256-pEKTL8YlOAem5QfNzLkjJaEDTp7PhtG/uyzjPzOL7Jo=";
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
