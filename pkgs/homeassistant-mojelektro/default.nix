{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:
buildHomeAssistantComponent rec {
  owner = "frlequ";
  domain = "mojelektro";
  version = "0.2.6";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-mojelektro";
    rev = "v${version}";
    hash = "sha256-uZ2v7M+xbdF/Gqqdq03N2IsQnI3T8LHos4xx2GBerqM=";
  };

  dependencies = [ home-assistant.python3Packages.requests ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Home Assistant integration for the Moj Elektro electricity meter";
    homepage = "https://github.com/frlequ/homeassistant-mojelektro";
    changelog = "https://github.com/frlequ/homeassistant-mojelektro/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
