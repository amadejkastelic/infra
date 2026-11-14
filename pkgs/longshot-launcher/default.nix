{
  lib,
  appimageTools,
  fetchurl,
}:
let
  version = "nightly-48-9b3d202b";

  src = fetchurl {
    url = "https://git.magicbean.dev/MagicBeanDev/LongshotLauncher/releases/download/${version}/LongshotLauncher-${version}-x86_64.AppImage";
    hash = "sha256-CwedFabqGg6w4ACIzqIAkQj7DSqdwYF7EUodUt7mt0k=";
  };

  appdir = appimageTools.extract {
    pname = "longshot-launcher";
    inherit version src;
  };
in
appimageTools.wrapType2 {
  pname = "longshot-launcher";
  inherit version src;

  extraPkgs =
    pkgs: with pkgs; [
      stdenv.cc.cc.lib
      fontconfig
      freetype
      libx11
      libxcb
      libxkbcommon
      wayland
      libGL
      icu
      openssl
    ];

  extraInstallCommands = ''
    install -Dm644 ${appdir}/longshot-launcher.desktop $out/share/applications/longshot-launcher.desktop
    install -Dm644 ${appdir}/longshot-launcher.png $out/share/icons/hicolor/512x512/apps/longshot-launcher.png
    substituteInPlace $out/share/applications/longshot-launcher.desktop \
      --replace-fail "Exec=LongshotLauncher" "Exec=longshot-launcher"
  '';

  passthru.updateScript = [ ./update.sh ];

  meta = {
    description = "Launcher for Longshot, the native PC recompilation of Zelda: Ocarina of Time (Nintendo Switch 2 remake)";
    longDescription = ''
      The Longshot Launcher (successor to RecompLauncher) is the Avalonia GUI
      front end of Longshot, the static recompilation of The Legend of Zelda:
      Ocarina of Time (Nintendo Switch 2 remake) running natively on Linux
      with no emulator. It installs the Longshot builder, builds the game
      from your own copy of it, keeps versions up to date, imports Hookshot
      saves and starts the game. Requires an AVX2 CPU and a Vulkan 1.3 GPU
      with mesh shader support.
    '';
    homepage = "https://longshot.magicbean.dev";
    changelog = "https://git.magicbean.dev/MagicBeanDev/LongshotLauncher/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "longshot-launcher";
  };
}
