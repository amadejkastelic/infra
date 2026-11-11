{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
}:
let
  pname = "hookshot";
  version = "2.1.0";
  src = fetchurl {
    url = "https://github.com/NotRexed/Hookshot/releases/download/v${version}/Hookshot-v${version}-x86_64.AppImage";
    hash = "sha256-wLLpWK4A3FYAchVPiQub5CJySr2btSLWr9mSJ4i4bgI=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/hookshot-builder.desktop $out/share/applications/hookshot-builder.desktop
    install -Dm644 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/hookshot.png $out/share/icons/hicolor/256x256/apps/hookshot.png
    substituteInPlace $out/share/applications/hookshot-builder.desktop \
      --replace-fail "Exec=AppRun" "Exec=hookshot"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  meta = {
    description = "Builder and launcher for the native PC recompilation of Zelda: Ocarina of Time (Nintendo Switch 2 remake)";
    longDescription = ''
      Hookshot is a static recompilation of The Legend of Zelda: Ocarina of
      Time (Nintendo Switch 2 remake) running natively on Linux with no
      emulator. The AppImage is Hookshot Builder: it carries its own toolchain
      (Python, clang and lld, a glibc 2.35 sysroot, FFmpeg, SDL2 and the
      prebuilt Vulkan back end) and builds the game on your PC from your own
      copy of it, then launches and updates the result. Requires an AVX2 CPU
      and a Vulkan 1.3 GPU with mesh shader support.
    '';
    homepage = "https://github.com/NotRexed/Hookshot";
    changelog = "https://github.com/NotRexed/Hookshot/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "hookshot";
  };
}
