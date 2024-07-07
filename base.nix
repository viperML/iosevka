{ nv
, buildNpmPackage
, remarshal
, ttfautohint-nox
, importNpmLock
,
}:
buildNpmPackage {

  pname = "iosevka-normal";
  inherit (nv) version src;

  npmDeps = importNpmLock {
    npmRoot = nv.src;
  };

  npmConfigHook = importNpmLock.npmConfigHook;

  postPatch = ''
    cp -v ${./private-build-plans.toml} private-build-plans.toml
  '';

  buildPhase = ''
    export HOME=$TMPDIR
    runHook preBuild
    npm run build --no-update-notifier --targets contents::iosevka-normal -- --jCmd=$NIX_BUILD_CORES --verbose=9
    runHook postBuild
  '';

  nativeBuildInputs = [
    remarshal
    ttfautohint-nox
  ];

  installPhase = ''
    mkdir -p $out
    cp -avL dist/* $out
  '';

  enableParallelBuilding = true;
}
