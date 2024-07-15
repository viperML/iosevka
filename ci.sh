#! /usr/bin/env bash
set -eux

export NIX_CONFIG="allow-import-from-derivation = true"

nix build .#iosevka-normal.base -L

DIST="$(realpath "${1:-$PWD/dist}")"
mkdir -p "$DIST"

# no need for ttf-only package
# pushd ./result/TTF
# zip -9 -r "$DIST/iosevka-ttf.zip" ./.
# popd

pushd ./result
zip -9 -r "$DIST/iosevka.zip" ./.
popd
