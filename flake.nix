{
  inputs = {
    # requirementes:
    # fontforge >= 20220308
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
    in
    {
      overlays.default = final: prev: {
        iosevka-normal = lib.makeScope final.newScope (self: {
          nv = (final.callPackages ./generated.nix { }).iosevka;
          base = self.callPackage ./base.nix { };
        });
      };

      legacyPackages.${system} = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
    };
}
