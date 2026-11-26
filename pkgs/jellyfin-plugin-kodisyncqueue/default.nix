{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "jellyfin-plugin-kodisyncqueue";

  version = "16";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-kodisyncqueue";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B90taUfnzd7LTY31ivUUMSrgBBV1PsH35ajevKFkzC4=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  enableParallelBuilding = false;

  projectFile = "Jellyfin.Plugin.KodiSyncQueue/Jellyfin.Plugin.KodiSyncQueue.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    mkdir -p $out/share/jellyfin/plugins/KodiSyncQueue
    cp $out/lib/${finalAttrs.pname}/Jellyfin.Plugin.KodiSyncQueue.dll \
      $out/lib/${finalAttrs.pname}/LiteDB.dll \
      $out/share/jellyfin/plugins/KodiSyncQueue/
  '';

  passthru.updateScript = [ ./update.sh ];
})
