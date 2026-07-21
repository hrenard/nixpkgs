{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  pixman,
  cairo,
  pango,
  nodejs,
  # typescript,
}:

buildNpmPackage (finalAttrs: {
  pname = "bgutil-ytdlp-pot-provider-server";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Brainicism";
    repo = "bgutil-ytdlp-pot-provider";
    tag = finalAttrs.version;
    hash = "sha256-WPLNjfVYDbPsEMVhjuF3dVarahdIKT7pt518SePfB8A=";
  };
  sourceRoot = "${finalAttrs.src.name}/server";

  npmDepsHash = "sha256-Qwwi6W+Oeu6ZeLmZP5vEfAKOJyivbULR5mlk7tcVIE8=";
  # npmDepsHash = lib.fakeHash;

  nativeBuildInputs = [
    pkg-config
    # typescript
  ];

  buildInputs = [
    pixman
    cairo
    pango
  ];

  # npmInstallFlags = [
  #   "--omit=dev"
  #   "--no-audit"
  #   "--no-fund"
  # ];

  # dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    npx tsc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/node_modules/bgutil-ytdlp-pot-provider-server}
    cp -r node_modules build $out/lib/node_modules/bgutil-ytdlp-pot-provider-server/
    makeWrapper "${lib.getExe nodejs}" "$out/bin/bgutil-ytdlp-pot-provider-server" \
      --add-flags "$out/lib/node_modules/bgutil-ytdlp-pot-provider-server/build/main.js"

    runHook postInstall
  '';

  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = {
    description = "Proof-of-origin token provider plugin for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hougo ];
  };
})
