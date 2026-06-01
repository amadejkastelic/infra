{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  pipewire,
  wl-clipboard,
  wtype,
  ydotool,
  libnotify,
  whisper-cpp-vulkan,
}:
buildGoModule (finalAttrs: {
  pname = "hyprvoice";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "LeonardoTrapani";
    repo = "hyprvoice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-geIjm5vChQwO44eSw8E9Tp8d4QkL3IGIdI7Xvpz9Eu8=";
  };

  vendorHash = "sha256-b1IsFlhj+xTQT/4PzL97YjVjjS7TQtcIsbeK3dLOxR4=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/hyprvoice \
      --prefix PATH : ${
        lib.makeBinPath [
          pipewire
          wl-clipboard
          wtype
          ydotool
          libnotify
          whisper-cpp-vulkan
        ]
      }
  '';

  nativeCheckInputs = [
    wl-clipboard
    wtype
    ydotool
  ];

  checkFlags = [
    # Tests require a running wayland compositor and pipewire
    "-skip=TestInjector|TestRecorder"
  ];

  meta = {
    description = "Voice-powered typing for Hyprland/Wayland";
    longDescription = ''
      Press a toggle key, speak, and get instant text input.
      Built natively for Wayland/Hyprland - no X11 hacks or workarounds,
      just clean integration with modern Linux desktops.
    '';
    homepage = "https://github.com/LeonardoTrapani/hyprvoice";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "hyprvoice";
    maintainers = with lib.maintainers; [ amadejkastelic ];
  };
})
