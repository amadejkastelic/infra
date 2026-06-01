{
  buildNpmPackage,
  fetchurl,
  lib,
  nodejs,
}:
buildNpmPackage rec {
  pname = "z-ai-vision-mcp-server";
  version = "0.1.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/@z_ai/mcp-server/-/mcp-server-${version}.tgz";
    sha256 = "sha256-CeWIqGjxwrTa3hDxGu6NIy+eQ+XHvO7gh2Nazt83J1w=";
  };

  npmDepsHash = "sha256-8gRm6R3hso6JpNEBFjoWkXUCOx4i/Z5u6HJiJdPzYR0=";

  dontNpmBuild = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}
    makeWrapper ${nodejs}/bin/node $out/bin/${pname} \
      --argv0 @z_ai/mcp-server \
      --set NIX_EXECUTABLE_DIR $out/bin \
      --add-flags "$out/lib/node_modules/${pname}"
    runHook postInstall
  '';

  meta = {
    mainProgram = pname;
    description = "MCP Server for Z.AI - Model Context Protocol server providing AI capabilities";
    homepage = "https://www.npmjs.com/package/@z_ai/mcp-server";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
