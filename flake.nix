{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
  in {
    overlays.default = final: prev: let
      buildPlan = builtins.fromTOML (builtins.readFile ./private-build-plans.toml);
      pname = builtins.head (builtins.attrNames buildPlan.buildPlans);
    in {
      ${pname} = lib.makeScope final.newScope (self: {
        base = self.callPackage ./base.nix {inherit pname;};

        # ready for linux use, though IFD
        ttf = final.runCommand "${pname}-ttf" {} ''
          dest=$out/share/fonts/truetype
          mkdir -p $dest
          cp -avL ${self.base}/TTF/*.ttf $dest
        '';
      });
    };

    legacyPackages.${system} = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
  };
}
