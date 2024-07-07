#! /usr/bin/env bash
set -eux

nix build .#iosevka-normal.base -L

DIST="$(realpath "${1:-$PWD/dist}")"
mkdir -p "$DIST"

pushd ./result/TTF
zip -9 -r "$DIST/iosevka-ttf.zip" ./.
popd

pushd ./result
zip -9 -r "$DIST/iosevka.zip" ./.
popd
