# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  iosevka = {
    pname = "iosevka";
    version = "v30.3.2";
    src = fetchFromGitHub {
      owner = "be5invis";
      repo = "Iosevka";
      rev = "v30.3.2";
      fetchSubmodules = false;
      sha256 = "sha256-Ksd1REqCe+42hpIwikIeKNYIYaHc5hqxuny8lYRuQcY=";
    };
    "package-lock.json" = builtins.readFile ./iosevka-v30.3.2/package-lock.json;
    "package.json" = builtins.readFile ./iosevka-v30.3.2/package.json;
  };
}
