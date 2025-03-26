{
  pname,
  # --
  buildNpmPackage,
  importNpmLock,
  remarshal,
  ttfautohint-nox,
  callPackages,
}: let
  nv = (callPackages ./_sources/generated.nix {
  }).iosevka;
in
  buildNpmPackage {
    inherit pname;
    inherit (nv) version src;

    npmDeps = importNpmLock {
      npmRoot = nv.src;
    };

    npmConfigHook = importNpmLock.npmConfigHook;

    nativeBuildInputs = [
      remarshal
      ttfautohint-nox
    ];

    postPatch = ''
      cp -v ${./private-build-plans.toml} private-build-plans.toml
    '';

    enableParallelBuilding = true;
    buildPhase = ''
      export HOME=$TMPDIR
      runHook preBuild
      trap "set +x" ERR
      set -x
      npm run build --no-update-notifier --targets contents::${pname} -- --jCmd=$NIX_BUILD_CORES --verbose=9
      set +x
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -avL dist/${pname}/* $out
      runHook postInstall
    '';
  }
