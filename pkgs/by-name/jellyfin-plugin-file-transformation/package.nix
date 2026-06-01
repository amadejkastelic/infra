{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-file-transformation";

  version = "2.5.3.0";

  src = fetchFromGitHub {
    owner = "IAmParadox27";
    repo = "jellyfin-plugin-file-transformation";
    tag = finalAttrs.version;
    hash = "sha256-N3rpTFBuGKi6RRLtS082mgxwRQWd9vDccLfsGGA7rd0=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "src/Jellyfin.Plugin.FileTransformation/Jellyfin.Plugin.FileTransformation.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    mkdir -p $out/share/jellyfin/plugins/FileTransformation
    cp $out/lib/${finalAttrs.pname}/Jellyfin.Plugin.FileTransformation.dll $out/share/jellyfin/plugins/FileTransformation/
  '';
})
