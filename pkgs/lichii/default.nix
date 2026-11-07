{
  lib,
  appimageTools,
  fetchurl,
}:
let
  version = "build-94";

  src = fetchurl {
    url = "https://github.com/zortos293/Lichii/releases/download/${version}/lichii-linux-x86_64.AppImage";
    hash = "sha256-kL59d8lB8AndgFkxvVYq5k4NeZFx0O/P5jrBoo13h/o=";
  };

  appdir = appimageTools.extract {
    pname = "lichii";
    inherit version src;
  };
in
appimageTools.wrapType2 {
  pname = "lichii";
  inherit version src;

  extraPkgs =
    pkgs: with pkgs; [
      e2fsprogs
      fontconfig
      freetype
      fribidi
      harfbuzz
      libgpg-error
      libusb1
      wayland
      libx11
      libxcb
      zlib
    ];

  extraInstallCommands = ''
    install -Dm644 ${appdir}/io.github.zortos293.lichii.desktop $out/share/applications/io.github.zortos293.lichii.desktop
    cp -r ${appdir}/usr/share/icons $out/share/icons
  '';

  passthru.updateScript = [ ./update.sh ];

  meta = {
    description = "Experimental Nintendo Switch and Switch 2 emulator";
    longDescription = ''
      Lichii is an experimental, open-source Nintendo Switch and Switch 2
      emulator written in C++, building on Eglantine, Eden, yuzu and Sudachi.
      Games, keys and firmware are not included.
    '';
    homepage = "https://github.com/zortos293/Lichii";
    changelog = "https://github.com/zortos293/Lichii/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lichii";
  };
}
