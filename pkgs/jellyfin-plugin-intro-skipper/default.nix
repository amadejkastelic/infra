{
  buildDotnetModule,
  fetchFromGitHub,
  fetchPnpmDeps,
  dotnetCorePackages,
  nodejs,
  pnpm,
  pnpmConfigHook,
  ...
}:
let
  branch = "12.0";
in
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-intro-skipper";

  version = "12.0.6.0";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = "intro-skipper";
    tag = "${branch}/v${finalAttrs.version}";
    hash = "sha256-KFUoRtlWDCYvr3528f08hDGtQlecJJjFYdD56gYjz1M=";
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
    hash = "sha256-vIyESmqTaPIPX2NWaE2DkGHXRXN+683bwktPMmnR7m8=";
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
