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
        ...
      }: let
        generated = pkgs.callPackage ./generated.nix {};
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            napalm.overlay
          ];
        };
        packages = {
          default = pkgs.napalm.buildPackage generated.iosevka.src {
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
              cp -av dist/*/ttf/* $out/share/fonts/truetype
            '';
          };
        };
      };
    };
}
