{
  lib,
  stdenv,
  fetchurl,
  unzip,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  qt5,
  alsa-lib,
  libusb1,
  libGL,
  libX11,
  libxcb,
  libSM,
  libICE,
  fontconfig,
  freetype,
  dbus,
  glib,
  zlib,
  xhost,
  xkeyboard-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "magewell-usb-capture-utility";
  version = "48315";

  src = fetchurl {
    url = "https://www.magewell.com/files/tools/USBCaptureUtility3_deb_${finalAttrs.version}.zip";
    hash = "sha256-YzxLRnov0NgfzYQKKeErA53naxucdbaWG+0p/0MVDnQ=";
  };

  nativeBuildInputs = [
    unzip
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtx11extras
    qt5.qtdeclarative
    qt5.qtsvg
    qt5.qtwayland
    alsa-lib
    libusb1
    libGL
    libX11
    libxcb
    libSM
    libICE
    fontconfig
    freetype
    dbus
    glib
    zlib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    unzip $src
    dpkg-deb --fsys-tarfile USBCaptureUtility3_deb_${finalAttrs.version}/usbcaptureutility_3.0.5.${finalAttrs.version}Internal.deb | tar --extract
  '';

  installPhase = ''
    runHook preInstall

    # Install the actual binary - let wrapQtAppsHook handle it
    install -Dm755 usr/local/bin/usbcaptureutility $out/bin/.usbcaptureutility-unwrapped
    install -Dm644 usr/local/bin/USBCaptureUtility.ini $out/bin/USBCaptureUtility.ini

    runHook postInstall
  '';

  postFixup = ''
    # Create the normal wrapper after Qt wrapping - force xcb platform and set XKB path
    makeWrapper $out/bin/.usbcaptureutility-unwrapped $out/bin/usbcaptureutility \
      --chdir "$out/bin" \
      --set QT_QPA_PLATFORM xcb \
      --set QT_SCALE_FACTOR 2 \
      --set-default QT_XKB_CONFIG_ROOT "${lib.getLib qt5.qtbase}/share/X11/xkb:${lib.getBin xkeyboard-config}/etc/X11/xkb"

    # Create pkexec wrapper with XKB path
    cat > $out/bin/usbcaptureutility-pkexec << EOF
    #!/bin/sh
    ${lib.getExe xhost} +si:localuser:root > /dev/null 2>&1
    pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY QT_QPA_PLATFORM=xcb QT_XKB_CONFIG_ROOT="${lib.getLib qt5.qtbase}/share/X11/xkb:${lib.getBin xkeyboard-config}/etc/X11/xkb" $out/bin/.usbcaptureutility-unwrapped "\$@"
    ${lib.getExe xhost} -si:localuser:root > /dev/null 2>&1
    EOF
    chmod +x $out/bin/usbcaptureutility-pkexec

    # Install polkit policy
    mkdir -p $out/share/polkit-1/actions
    cat > $out/share/polkit-1/actions/com.magewell.usbcaptureutility.policy << EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE policyconfig PUBLIC
    "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
    "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
    <policyconfig>
      <action id="com.magewell.usbcaptureutility.pkexec">
        <description>Run Magewell USB Capture Utility</description>
        <message>Authentication is required to run USB Capture Utility with elevated privileges</message>
        <defaults>
          <allow_any>auth_admin</allow_any>
          <allow_inactive>auth_admin</allow_inactive>
          <allow_active>auth_admin</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">$out/bin/.usbcaptureutility-unwrapped</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
      </action>
    </policyconfig>
    EOF
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "usbcaptureutility";
      exec = "usbcaptureutility-pkexec";
      icon = "usbcaptureutility";
      desktopName = "USB Capture Utility";
      genericName = "Magewell USB Capture Utility";
      categories = [
        "AudioVideo"
        "Utility"
      ];
      comment = "Configure and manage Magewell USB capture devices";
    })
  ];

  meta = {
    description = "Magewell USB Capture Utility for configuring USB capture devices";
    homepage = "https://www.magewell.com/usb-capture";
    platforms = [ "x86_64-linux" ];
    mainProgram = "usbcaptureutility";
  };
})
