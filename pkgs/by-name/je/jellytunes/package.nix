{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  copyDesktopItems,
  icoutils,
  makeWrapper,
  makeDesktopItem,
  electron,
  nodejs,
  pnpm,
  pnpmConfigHook,
  pnpmBuildHook,
  fetchPnpmDeps,
  sqlite,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jellytunes";
  version = "0.7.2";
  # strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "orainlabs";
    repo = "jellytunes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gDdabA7UOGWtotXU0603t1HJrr72lRj1prI2qlg3R54=";
  };

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpmBuildHook
    pnpm # At least required by pnpmConfigHook and pnpmBuildHook, if not other (custom) phases
    copyDesktopItems
    icoutils
    makeWrapper
    sqlite
    python3
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-d7YtyeWwerJlVOr+rDLUECISKdAOcB9YweBnQr2j1I4=";
  };

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  pnpmBuildScript = "package";

  # desktopItems = with finalAttrs; [
  #   (makeDesktopItem {
  #     name = pname;
  #     desktopName = "AriaNg Native";
  #     genericName = meta.description;
  #     comment = meta.description;
  #     icon = pname;
  #     exec = "${pname} %U";
  #     mimeTypes = [ "x-scheme-handler/magnet" ];
  #     categories = [ "Network" ];
  #     startupWMClass = pname;
  #   })
  # ];

  # postInstall = with finalAttrs; ''
  #   # Create desktop icons
  #   icotool -x assets/AriaNg.ico
  #   ls *.png | sort -V | while read -r file; do
  #     size=$(echo "$file" | awk -F '_' '{print $3}' | cut -d 'x' -f 1)
  #     mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
  #     mv "$file" "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
  #   done

  #   makeWrapper ${lib.getExe electron} $out/bin/${pname} \
  #     --inherit-argv0 \
  #     --add-flags "$out/lib/node_modules/${pname}"
  # '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Take your Jellyfin music offline on MP3 players and storage devices";
    homepage = "https://github.com/orainlabs/jellytunes";
    changelog = "https://github.com/orainlabs/jellytunes/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hougo ];
    mainProgram = finalAttrs.pname;
    platforms = lib.platforms.linux;
  };
})
