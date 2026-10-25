{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:
buildHomeAssistantComponent rec {
  owner = "MarZab";
  domain = "mojelektro_stats";
  version = "0-unstable-2026-06-28";

  src = fetchFromGitHub {
    inherit owner;
    repo = "mojelektro-stats";
    rev = "f546fce43ca4e4cd0dbdd6255f33ca4ceaab417b";
    hash = "sha256-NSi1fyx59uBdQkrqJTaqCDWl6f4H4QRr37RuiQehQ1U=";
  };

  patches = [ ./statistics-day-attribution.patch ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "Home Assistant integration importing Moj Elektro electricity data into long-term statistics";
    homepage = "https://github.com/MarZab/mojelektro-stats";
    license = lib.licenses.free;
  };
}
