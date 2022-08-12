{pkgs, ...}: {
  iosevka.build = {
    nativeBuildInputs = [
      pkgs.ttfautohint
    ];
    postConfigure = ''
      cp -v ${../../plans.toml} private-build-plans.toml
    '';
    buildPhase = ''
      runHook preBuild
      # npm run build --no-update-notifier -- ttf::iosevka-normal >/dev/null
      npm run build -- ttf::iosevka-normal
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype
      cp -av dist/*/ttf/* $out/share/fonts/truetype
      chmod -R +w $out/lib
      rm -rf $out/lib
      runHook postInstall
    '';
  };
}
