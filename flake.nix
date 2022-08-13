{
  description = "flake-parts based template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iosevka = {
      url = "github:be5invis/Iosevka/v15.6.3";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    dream2nix,
    iosevka,
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [
        (import ./module.nix dream2nix)
      ];

      systems = [
        "x86_64-linux"
      ];

      dream = {
        config = {
          projectRoot = ./.;
          overridesDirs = [
            "${dream2nix}/overrides"
            ./overrides
          ];
        };
        source = iosevka;
      };

      perSystem = {
        pkgs,
        self',
        ...
      }: {
        packages.zipfile =
          pkgs.runCommand "iosevka-zip" {
            src = self'.packages.iosevka;
            nativeBuildInputs = [
              pkgs.zip
            ];
          } ''
            WORKDIR="$PWD"
            cd $src/share/fonts/truetype
            zip "$WORKDIR/iosevka.zip" *
            cp -av "$WORKDIR/iosevka.zip" $out
          '';
      };
    };
}
