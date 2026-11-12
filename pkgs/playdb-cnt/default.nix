{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      cryptography
      grpcio
      tkinter
      zstandard
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "playdb-cnt";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "sikoGD";
    repo = "playDB-CNT";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r5vBlfk9+waaw42WrUY/fbPBER4wdv3S9XIArhB8PNc=";
  };

  buildPhase = ''
    runHook preBuild
    $CXX -O2 -w -msse4.1 \
      tools/ooz/source/kraken.cpp tools/ooz/source/bitknit.cpp tools/ooz/source/lzna.cpp \
      -o ooz
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/playdb-cnt
    cp -r play_duskbloods.py dusk_mods.py tools assets $out/share/playdb-cnt/
    rm -f $out/share/playdb-cnt/tools/ooz/ooz.exe
    rm -rf $out/share/playdb-cnt/tools/ooz/source
    rm -rf $out/share/playdb-cnt/tools/online_shim
    install -Dm555 ooz $out/share/playdb-cnt/tools/ooz/ooz

    install -Dm755 ${./play-duskbloods} $out/bin/play-duskbloods
    substituteInPlace $out/bin/play-duskbloods \
      --replace-fail "@share@" "$out/share/playdb-cnt" \
      --replace-fail "@python@" "${pythonEnv}/bin/python"

    install -Dm644 assets/icon.png $out/share/icons/hicolor/256x256/apps/playdb-cnt.png
    mkdir -p $out/share/applications
    cat > $out/share/applications/playdb-cnt.desktop <<DESKTOP
    [Desktop Entry]
    Type=Application
    Name=Play Duskbloods
    Comment=Launcher for The Duskbloods network test on Eglantine-based Switch 2 emulators
    Exec=play-duskbloods
    Icon=playdb-cnt
    Terminal=false
    Categories=Game;
    DESKTOP

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version-regex"
      "^v(.*)$"
    ];
  };

  meta = {
    description = "Launcher for The Duskbloods network test on Switch 2 emulators with local stand-in servers";
    longDescription = ''
      playDB-CNT runs The Duskbloods Network Test on Eglantine-based Switch 2
      emulators (Eglantine, Lichii, Eden) with the game's online services
      served by local stand-in servers: offline loopback-only play, online
      rooms with friends, and Bot Match, a full match against 7 CPU players.
      Games, keys and firmware are not included.
    '';
    homepage = "https://github.com/sikoGD/playDB-CNT";
    changelog = "https://github.com/sikoGD/playDB-CNT/releases/tag/v${finalAttrs.version}";
    platforms = [ "x86_64-linux" ];
    mainProgram = "play-duskbloods";
    maintainers = with lib.maintainers; [ amadejkastelic ];
  };
})
