{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
let
  branch = "10.11";
in
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-intro-skipper";

  version = "1.10.11.14";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = "intro-skipper";
    tag = "${branch}/v${finalAttrs.version}";
    hash = "sha256-NMwBaghTSph1bNwo1xQAEnfEwf+XGFbTmcOORQzz6yQ=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "IntroSkipper/IntroSkipper.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    mkdir -p $out/share/jellyfin/plugins/IntroSkipper
    cp $out/lib/${finalAttrs.pname}/IntroSkipper.dll $out/share/jellyfin/plugins/IntroSkipper/
  '';
})
