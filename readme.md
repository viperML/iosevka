# viperML/iosevka

This is my custom iosevka config.

Grab the latest zip file from
[releases](https://github.com/viperML/iosevka/releases) or build the fonts with
nix.

```
$ nix build github:viperML/iosevka#iosevka-normal.base -L
```

![](./screenshot.png)

## Symbols

Nerd fonts are not patched into the font. It is kind of a hack, and all
terminals/editors I use support font fallback.

Download symbols separately: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/NerdFontsSymbolsOnly


## Forking

It should be easy to fork this repo to use your [custom build
plan](./private-build-plans.toml).

## IFD

This nix flake uses [Import From Derivation](https://wiki.nixos.org/wiki/Import_From_Derivation)
to import the `package-lock.json`. Feel free to change this
behavior to use a fixed hash.
