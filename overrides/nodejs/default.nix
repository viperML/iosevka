{pkgs, ...}: {
  iosevka = {
    add-inputs.nativeBuildInputs = old:
      old
      ++ [
        pkgs.ttfautohint
      ];
    build = {
      preBuild = ''
        cp -v ${../../plans.toml} private-build-plans.toml
      '';
      buildScript = ''
        npm run build --no-update-notifier -- ttf::iosevka-normal >/dev/null
      '';
    };
  };
}
