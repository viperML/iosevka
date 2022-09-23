{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    napalm = {
      url = "github:nix-community/napalm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    napalm,
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = {
        pkgs,
        system,
        config,
        ...
      }: let
        nv = (pkgs.callPackage ./generated.nix {}).iosevka;
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            napalm.overlay
          ];
        };
        packages = {
          default = config.packages.base;

          base = pkgs.napalm.buildPackage nv.src {
            inherit (nv) pname version;
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

          # nerd-font-patcher = pkgs.nerd-font-patcher.overrideAttrs (old: rec {
          #   version = "2.2.2";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "ryanoasis";
          #     repo = "nerd-fonts";
          #     rev = "v${version}";
          #     sparseCheckout = ''
          #       font-patcher
          #       /src/glyphs
          #     '';
          #     hash = "sha256-gGhbwlkQhVpWoifF9R9RiRRMHTxIfKjiMZ1liIIkx8c=";
          #   };
          # });

          base-nerd = pkgs.stdenvNoCC.mkDerivation {
            inherit (nv) pname version;
            src = config.packages.base;
            nativeBuildInputs = [
              pkgs.nerd-font-patcher
            ];
            buildPhase = ''
              shopt nullglob
              set +x
              trap 'set +x' ERR

              mkdir -p $out
              for file in ./*; do
                nerd-font-patcher \
                  --mono \
                  --adjust-line-height \
                  --complete \
                  --careful \
                  --no-progressbars \
                  --outputdir $out \
                  $file
              done

              set +x
            '';
            dontInstall = true;
          };

          # web = pkgs.napalm.buildPackage nv.src {
          #   pname = "${nv.pname}-web";
          #   inherit (nv) version;
          #   npmCommands = [
          #     "npm install"
          #     "npm run build --no-update-notifier -- webfont::iosevka-normal >/dev/null"
          #   ];
          #   nativeBuildInputs = [
          #     pkgs.ttfautohint
          #   ];
          #   postPatch = ''
          #     cp ${./private-build-plans.toml} private-build-plans.toml
          #   '';
          #   installPhase = ''
          #     mkdir -p $out
          #     find dist -type f -name '*.woff2' -exec cp -v '{}' $out \;
          #     find dist -type f -name '*.css' -exec cp -v '{}' $out \;
          #   '';
          # };

          zip-nerd =
            pkgs.runCommand "iosevka-zip" {
              src = config.packages.default;
              nativeBuildInputs = [
                pkgs.zip
              ];
            } ''
              WORKDIR="$PWD"
              cd $src
              zip "$WORKDIR/iosevka.zip" *
              cp -av "$WORKDIR/iosevka.zip" $out
            '';

          # web-zipfile =
          #   pkgs.runCommand "iosevka-web-zip" {
          #     src = self'.packages.web;
          #     nativeBuildInputs = [
          #       pkgs.zip
          #     ];
          #   } ''
          #     WORKDIR="$PWD"
          #     cd $src
          #     zip "$WORKDIR/iosevka.zip" *
          #     cp -av "$WORKDIR/iosevka.zip" $out
          #   '';

          # nerd-fonts-src = pkgs.fetchFromGitHub {
          #   owner = "ryanoasis";
          #   repo = "nerd-fonts";
          #   rev = "v2.1.0";
          #   sparseCheckout = ''
          #     src/glyphs
          #   '';
          #   hash = "sha256-Vhyd1jCsDNIVNE/WF2bxAcmRguEwj6i3OqBC1fxi1S4=";
          # };
        };
      };
    };
}
