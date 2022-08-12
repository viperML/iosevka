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
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    dream2nix,
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = [
        "x86_64-linux"
      ];
      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: let
        nv = (pkgs.callPackage ./generated.nix {}).iosevka;
        dreamLib = dream2nix.lib.init {
          inherit pkgs;
          config = {
            projectRoot = ./.;
            overridesDirs = [
              "${dream2nix}/overrides"
              ./overrides
            ];
          };
        };
        dream = dreamLib.makeOutputs {
          source = nv.src;
        };
      in {
        packages = {
          default = dream.packages.iosevka;
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
        };
      };
    };
}
