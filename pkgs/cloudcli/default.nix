{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs,
  python3,
  ripgrep,
}:
buildNpmPackage rec {
  pname = "cloudcli";
  version = "1.37.11";

  src = fetchFromGitHub {
    owner = "siteboon";
    repo = "claudecodeui";
    tag = "v${version}";
    hash = "sha256-FlsrM9OQFdSsHS461S73tpkyIX8jPXQrxCLnMDiEFU8=";
  };

  npmDepsHash = "sha256-IYGY9OM2VEA6k8heSCs7vUU2XDKvFaMnaG72S9/lvlg=";

  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ python3 ];

  postBuild = ''
    ${nodejs}/bin/node scripts/promote-dist-server.mjs
    ${nodejs}/bin/npm rebuild better-sqlite3
  '';

  installPhase = ''
    runHook preInstall
    install -D ${lib.getExe ripgrep} node_modules/@vscode/ripgrep/bin/rg
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}
    makeWrapper ${nodejs}/bin/node $out/bin/${pname} \
      --argv0 cloudcli \
      --add-flags "$out/lib/node_modules/${pname}/dist-server/server/modules/cli/cli.js"
    runHook postInstall
  '';

  passthru.updateScript = [ ./update.sh ];

  meta = {
    mainProgram = pname;
    description = "CloudCLI - web interface for Claude Code and other coding agents";
    homepage = "https://github.com/siteboon/claudecodeui";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.unix;
  };
}
