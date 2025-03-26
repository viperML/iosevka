{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
    in
    {
      overlays.default =
        final: prev:
        let
          buildPlan = builtins.fromTOML (builtins.readFile ./private-build-plans.toml);
          pname = builtins.head (builtins.attrNames buildPlan.buildPlans);
        in
        {
          ${pname} = lib.makeScope final.newScope (self: {
            base = self.callPackage ./base.nix { inherit pname; };

            base-zip = final.runCommand "${pname}-base.zip" { nativeBuildInputs = with final; [ zip ]; } ''
              mkdir work
              cd work
              cp -vr ${self.base}/* .
              zip -9 -r "$out" ./.
            '';

            # ready for linux use, though IFD
            ttf = final.runCommand "${pname}-ttf" { } ''
              dest=$out/share/fonts/truetype
              mkdir -p $dest
              cp -avL ${self.base}/TTF/*.ttf $dest
            '';

            web = final.runCommand "${pname}-web" { } ''
              mkdir -p $out
              cp -vr ${./web-skeleton}/{*,.*} $out
              cp -vr ${self.base}/{*.css,WOFF*} $out
            '';
          });
        };

      legacyPackages.${system} = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
    };
}
