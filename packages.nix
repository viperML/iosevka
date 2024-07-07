{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    config,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.napalm.overlays.default
      ];
    };

    packages = let
      plan = "iosevka-normal";
      nv = (pkgs.callPackage ./generated.nix {}).iosevka;
      version = lib.removePrefix "v" nv.version;
      mkZip = src: let
        pname = "${src.pname}-zip";
      in
        pkgs.runCommand "${pname}-${version}" {
          inherit pname src version;
          nativeBuildInputs = [
            pkgs.zip
          ];
        } ''
          WORKDIR="$PWD"
          cd $src
          zip "$WORKDIR/iosevka.zip" *
          cp -av "$WORKDIR/iosevka.zip" $out
        '';

      mkLinux = src: let
        pname = "${src.pname}-linux";
      in
        pkgs.runCommand "${pname}-${src.version}" {
          inherit pname src version;
        } ''
          mkdir -p $out/share/fonts/truetype
          cp -v $src/* $out/share/fonts/truetype
        '';
    in {
      inherit (nv) src;

      default = config.packages.ttf-nerd-zip;

      ttf = pkgs.napalm.buildPackage nv.src {
        pname = "${plan}-ttf";
        inherit version;
        npmCommands = [
          "npm install"
          "npm run build --no-update-notifier -- ttf::iosevka-normal >/dev/null"
        ];
        nativeBuildInputs = [
          pkgs.ttfautohint
        ];
        postPatch = ''
          cp -v ${./private-build-plans.toml} private-build-plans.toml
        '';
        installPhase = ''
          mkdir -p $out
          cp -avL dist/*/ttf/* $out
        '';
      };

      ttf-nerd = pkgs.stdenvNoCC.mkDerivation {
        pname = "${plan}-ttf-nerd";
        inherit version;
        src = config.packages.ttf;
        nativeBuildInputs = [
          pkgs.nerd-font-patcher
        ];
        buildPhase = ''
          set -x
          trap 'set +x' ERR

          mkdir -p $out
          for file in ./*; do
            nerd-font-patcher \
              --mono \
              --careful \
              --windows \
              --complete \
              --no-progressbars \
              --outputdir $out \
              $file &> /dev/null
          done

          set +x
        '';
        dontInstall = true;
      };

      ttf-zip = mkZip config.packages.ttf;
      ttf-nerd-zip = mkZip config.packages.ttf-nerd;

      ttf-linux = mkLinux config.packages.ttf;
      ttf-nerd-linux = mkLinux config.packages.ttf-nerd;

      ####
      # web versions
      ####

      web = pkgs.napalm.buildPackage nv.src {
        pname = "${plan}-web";
        inherit version;
        npmCommands = [
          "npm install"
          "npm run build --no-update-notifier -- webfont::iosevka-normal >/dev/null"
        ];
        nativeBuildInputs = [
          pkgs.ttfautohint
        ];
        postPatch = ''
          cp ${./private-build-plans.toml} private-build-plans.toml
        '';
        installPhase = ''
          mkdir -p $out
          find dist -type f -name '*.woff2' -exec cp -v '{}' $out \;
          find dist -type f -name '*.css' -exec cp -v '{}' $out \;
        '';
      };

      web-zip = mkZip config.packages.web;
    };
  };
}
