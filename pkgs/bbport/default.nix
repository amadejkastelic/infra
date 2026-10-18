{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  appimage-run,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bbport";
  version = "0.51";

  src = fetchurl {
    url = "https://github.com/deadinside28/bloodborne_pc/releases/download/${finalAttrs.version}/Bloodborne-bbport-x86_64.AppImage";
    hash = "sha256-Pbvsgorr1UJiLPJfDqEKFvULE/i1M4+2WWoaaaY1/M4=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm555 $src $out/share/bbport/Bloodborne-bbport-x86_64.AppImage
    makeWrapper ${lib.getExe appimage-run} $out/bin/bbport \
      --add-flags "$out/share/bbport/Bloodborne-bbport-x86_64.AppImage"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Native Linux port of Bloodborne running the PS4 game executable directly on x86-64";
    longDescription = ''
      bbport runs Bloodborne's own x86-64 executable on the CPU, replaces PS4
      system libraries with a purpose-built runtime, and translates the GPU
      command stream to Vulkan. The AppImage is fully self-contained: it
      bundles its own Nix store, chroots into it at startup, and only exposes
      host top-level directories, so it is run through appimage-run which
      extracts it below ~/.cache where the chroot can still see it. No game
      files are included: a decrypted dump of the game at version 1.09 is
      required.
    '';
    homepage = "https://github.com/deadinside28/bloodborne_pc";
    changelog = "https://github.com/deadinside28/bloodborne_pc/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "bbport";
  };
})
