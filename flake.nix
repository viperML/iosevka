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
        self',
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
          default = pkgs.napalm.buildPackage nv.src {
            inherit (nv) pname version;
            npmCommands = [
              "npm install"
              "npm run build --no-update-notifier -- ttf::iosevka-normal >/dev/null"
            ];
            nativeBuildInputs = [
              pkgs.ttfautohint
            ];
            postPatch = ''
              cp ${./private-build-plans.toml} private-build-plans.toml
            '';
            installPhase = ''
              mkdir -p $out/share/fonts/truetype
              cp -avL dist/*/ttf/* $out/share/fonts/truetype
              cp -avL "${self'.packages.nerd-fonts-src}/src/glyphs/Symbols-1000-em Nerd Font Complete.ttf" $out/share/fonts/truetype
            '';
          };

          web = pkgs.napalm.buildPackage nv.src {
            pname = "${nv.pname}-web";
            inherit (nv) version;
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

          zipfile =
            pkgs.runCommand "iosevka-zip" {
              src = self'.packages.default;
              nativeBuildInputs = [
                pkgs.zip
              ];
            } ''
              WORKDIR="$PWD"
              cd $src/share/fonts/truetype
              zip "$WORKDIR/iosevka.zip" *
              cp -av "$WORKDIR/iosevka.zip" $out
            '';

          web-zipfile =
            pkgs.runCommand "iosevka-web-zip" {
              src = self'.packages.web;
              nativeBuildInputs = [
                pkgs.zip
              ];
            } ''
              WORKDIR="$PWD"
              cd $src
              zip "$WORKDIR/iosevka.zip" *
              cp -av "$WORKDIR/iosevka.zip" $out
            '';

          nerd-fonts-src = pkgs.fetchFromGitHub {
            owner = "ryanoasis";
            repo = "nerd-fonts";
            rev = "v2.1.0";
            sparseCheckout = ''
              src/glyphs
            '';
            hash = "sha256-Vhyd1jCsDNIVNE/WF2bxAcmRguEwj6i3OqBC1fxi1S4=";
          };
        };
      };
    };
}
