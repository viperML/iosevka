#! /usr/bin/env bash
set -eux

nix build .#iosevka-normal.base -L

DIST="$(realpath "${1:-$PWD/dist}")"
mkdir -p "$DIST"

pushd ./result/TTF
zip "$DIST/iosevka-ttf.zip" ./*.ttf
popd

pushd ./result
zip "$DIST/iosevka.zip" ./*
popd
