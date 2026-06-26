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
  branch = "10.11";
in
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-intro-skipper";

  version = "1.10.11.21";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = "intro-skipper";
    tag = "${branch}/v${finalAttrs.version}";
    hash = "sha256-/Gxvcm8pbFe8py/9gvqrW7S2+Zzlrz9sSFwHBrgE1AU=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "IntroSkipper/IntroSkipper.csproj";
  nugetDeps = ./deps.json;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname src;
    preInstall = "cd web";
    fetcherVersion = 4;
    hash = "sha256-xMS1lZaM45qT6kdpJrp2aBdZfWcNceMc01DuK6DccSg=";
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
})
