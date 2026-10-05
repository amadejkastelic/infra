{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-mattpocock-skills";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version-regex"
      "^v(.*)$"
    ];
  };

  meta.description = "Matt Pocock's Claude Code skills for engineering and productivity workflows";
})
