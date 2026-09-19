{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  fetchPnpmDeps,
  dotnetCorePackages,
  jellyfin,
  nodejs,
  pnpm,
  pnpmConfigHook,
  ...
}:
let
  branch = lib.versions.majorMinor jellyfin.version;
in
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-intro-skipper";

  version = "12.0.4.0";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = "intro-skipper";
    tag = "${branch}/v${finalAttrs.version}";
    hash = "sha256-LzNM5aQ7qjqxMqizlG3VpUHrt6a5SHPQf3AHaDhaNrM=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  enableParallelBuilding = false;

  projectFile = "IntroSkipper/IntroSkipper.csproj";
  nugetDeps = ./deps.json;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname src;
    preInstall = "cd web";
    fetcherVersion = 4;
    hash = "sha256-Krukkmbu9zgEAkxXfY538a5tcWhCOnSWP3Ld400U3+8=";
  };

  pnpmRoot = "web";

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ];

  dotnet-build-flags = [ "/p:SkipWebBuild=true" ];

  preBuild = ''
    (cd "$pnpmRoot" && pnpm build)
  '';

  postFixup = ''
    mkdir -p $out/share/jellyfin/plugins/IntroSkipper
    cp $out/lib/${finalAttrs.pname}/IntroSkipper.dll $out/share/jellyfin/plugins/IntroSkipper/
  '';

  passthru.updateScript = [ ./update.sh ];
})
