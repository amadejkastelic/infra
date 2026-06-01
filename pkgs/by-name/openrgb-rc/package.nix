{
  lib,
  stdenv,
  fetchFromGitLab,
  libusb1,
  hidapi,
  pkg-config,
  coreutils,
  mbedtls,
  symlinkJoin,
  kdePackages,
  openrgb-plugin-effects,
  openrgb-plugin-hardwaresync,
}:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/op/openrgb/package.nix
let
  base = stdenv.mkDerivation (finalAttrs: {
    pname = "openrgb";
    version = "unstable-2026-04-26";

    # https://gitlab.com/CalcProgrammer1/OpenRGB/-/merge_requests/3290
    src = fetchFromGitLab {
      owner = "amadejkastelic";
      repo = "OpenRGB";
      rev = "c1380b56c3bbcd68ac61967835a1d8d14b04ae7e";
      hash = "sha256-Sa46/eitQ9Bgrys2a3tBa+LlhXr0wIbALkQYYDXVCLA=";
    };

    nativeBuildInputs = [
      pkg-config
    ]
    ++ (with kdePackages; [
      qmake
      wrapQtAppsHook
    ]);

    buildInputs = [
      libusb1
      hidapi
      mbedtls
    ]
    ++ (with kdePackages; [
      qtbase
      qttools
      qtwayland
    ]);

    patches = [
      ./remove-systemd.patch
    ];

    postPatch = ''
      patchShebangs scripts/build-udev-rules.sh
      substituteInPlace scripts/build-udev-rules.sh \
        --replace-fail /usr/bin/env "${coreutils}/bin/env"
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      HOME=$TMPDIR $out/bin/openrgb --help > /dev/null

      runHook postInstallCheck
    '';

    qmakeFlags = [
      "QT_TOOL.lrelease.binary=${lib.getDev kdePackages.qttools}/bin/lrelease"
    ];

    passthru.withPlugins =
      plugins:
      let
        pluginsDir = symlinkJoin {
          name = "openrgb-plugins";
          paths = plugins;
          # Remove all library version symlinks except one,
          # or they will result in duplicates in the UI.
          # We leave the one pointing to the actual library, usually the most
          # qualified one (eg. libOpenRGBHardwareSyncPlugin.so.1.0.0).
          postBuild = ''
            for f in $out/lib/*; do
              if [ "$(dirname $(readlink "$f"))" == "." ]; then
                rm "$f"
              fi
            done
          '';
        };
      in
      finalAttrs.finalPackage.overrideAttrs (old: {
        qmakeFlags = old.qmakeFlags or [ ] ++ [
          # Welcome to Escape Hell, we have backslashes
          ''DEFINES+=OPENRGB_EXTRA_PLUGIN_DIRECTORY=\\\""${
            lib.escape [ "\\" "\"" " " ] (toString pluginsDir)
          }/lib\\\""''
        ];
      });

    meta = {
      description = "Open source RGB lighting control";
      homepage = "https://gitlab.com/CalcProgrammer1/OpenRGB";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
      mainProgram = "openrgb";
    };
  });
in
base.withPlugins [
  openrgb-plugin-effects
  openrgb-plugin-hardwaresync
]
