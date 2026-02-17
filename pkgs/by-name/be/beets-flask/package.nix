{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  nodejs,
  pnpm,
  npmHooks,
}:

python3Packages.buildPythonPackage rec {
  pname = "beets-flask";
  version = "1.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pSpitzner";
    repo = "beets-flask";
    rev = "v${version}";
    hash = "sha256-VdNVUhm8JlRLtpRC94ruENpSbJXRFuTvo5YdBSHztJU=";
  };

  sourceRoot = "${src.name}/backend";

  # postPatch = ''
  #   # don't test bash builtins
  #   rm testing/test_argcomplete.py
  # '';

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    quart
    confuse
    beets
    sqlalchemy
    rq
    watchdog
    requests
    python-socketio
    pillow
    cachetools
    libtmux
    # Deprecated
    nest-asyncio
    pylast
    # python2ts
    natsort
    tinytag
    pydub
    aiohttp
    aiofiles
    numpy
    pandas
    # typing_extensions
  ];

  pythonRelaxDeps = [
    "beets"
  ];

  pythonRemoveDeps = [
    "uvicorn"
    "python2ts"
  ];

  # nativeCheckInputs = with python3Packages; [
  #   uvicorn
  #   python2ts
  # ];

  passthru.frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "${pname}-frontend";
    inherit src version meta;

    # pnpmRoot = "frontend";
    sourceRoot = "${finalAttrs.src.name}/frontend";


    nativeBuildInputs = [
      nodejs
      pnpm.configHook
      # npmHooks.npmInstallHook
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      sourceRoot = "${finalAttrs.src.name}/frontend";
      hash = "sha256-IxY2e6+EQrqjaUpqbmaSNdV5l4M3GosGNRljtayOnD0=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    
  });

  meta = {
    changelog = "https://github.com/pSpitzner/beets-flask/releases/tag/v${version}";
    description = "Framework for writing tests";
    homepage = "https://beets-flask.readthedocs.io/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      hougo
    ];
  };
}
