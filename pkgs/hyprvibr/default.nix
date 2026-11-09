{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  hyprland,
}:

hyprland.stdenv.mkDerivation (finalAttrs: {
  pname = "hyprvibr";
  version = "0-unstable-2026-11-03";

  src = fetchFromGitHub {
    owner = "devcexx";
    repo = "hyprvibr";
    rev = "87ee4e4f0ae6db9c8005ab4470d2a625ead4f797";
    hash = "sha256-EEE1AIxRHo3WOqh/6jSyX+Lm+uJ/AoL+UgVlZGBJJuY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ hyprland ] ++ hyprland.buildInputs;

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp out/hyprvibr.so $out/lib/libhyprvibr.so

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "libvibrant-like Hyprland plugin for per-focused-window monitor saturation";
    homepage = "https://github.com/devcexx/hyprvibr";
    platforms = lib.platforms.linux;
  };
})
