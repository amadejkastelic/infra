{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  procps,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "lichii-shader-sync";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "oceanpacificpeace";
    repo = "lichii-shader-sync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pZlzzAk0iDH6TEZj3xCl0ItUsU9th/C51meZRQM2E84=";
  };

  vendorHash = "sha256-tw6CETra9FkaZpJ1oqjQQzO7gvfNv5ZYnGHakbr0G3I=";

  subPackages = [ "." ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/lichii-sync --prefix PATH : ${lib.makeBinPath [ procps ]}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version-regex"
      "^v(.*)$"
    ];
  };

  meta = {
    description = "Syncs shared Vulkan shader cache packs into Lichii/Eden from GitHub releases";
    longDescription = ''
      Downloads community shader caches per game title ID so games stutter
      less on first play. Every download is checksum-verified and the previous
      cache is kept as .bak. Also ships maintainer commands to build and
      publish new packs (pack) and to export shaders the online pack lacks
      (export). The Windows-only GUI is not built.
    '';
    homepage = "https://github.com/oceanpacificpeace/lichii-shader-sync";
    changelog = "https://github.com/oceanpacificpeace/lichii-shader-sync/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "lichii-sync";
    maintainers = with lib.maintainers; [ amadejkastelic ];
  };
})
