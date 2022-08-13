dream2nix: {
  config,
  lib,
  flake-parts-lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;
in {
  options.dream = mkOption {
    type = types.attrs;
    default = {};
  };

  config = {
    flake = dream2nix.lib.makeFlakeOutputs (config.dream
      // {
        systems = config.systems;
      });
  };
}
