{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "MarZab";
  domain = "mojelektro_stats";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = "mojelektro-stats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xKcWZVewgJJVb0S0brF095pCEY29MWdDD9zxn1kVHso=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--override-filename"
      "pkgs/homeassistant-mojelektro-stats/default.nix"
    ];
  };

  meta = {
    description = "Home Assistant integration importing Moj Elektro electricity data into long-term statistics";
    homepage = "https://github.com/MarZab/mojelektro-stats";
    license = lib.licenses.mit;
  };
})
