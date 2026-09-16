{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-file-transformation";

  version = "3.0.1.0";

  src = fetchFromGitHub {
    owner = "IAmParadox27";
    repo = "jellyfin-plugin-file-transformation";
    tag = finalAttrs.version;
    hash = "sha256-c1u4vMki8dsTM/vpvpm0/ipAP3wmeiLq+JjRDI3Mcpc=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  enableParallelBuilding = false;

  projectFile = "src/Jellyfin.Plugin.FileTransformation/Jellyfin.Plugin.FileTransformation.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    mkdir -p $out/share/jellyfin/plugins/FileTransformation
    cp $out/lib/${finalAttrs.pname}/Jellyfin.Plugin.FileTransformation.dll $out/share/jellyfin/plugins/FileTransformation/
  '';

  passthru.updateScript = [ ./update.sh ];
})
