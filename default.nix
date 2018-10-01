let
  pkgs = import <nixpkgs> {};
in
{ stdenv ? pkgs.stdenv, jekyll ? pkgs.jekyll,
  graphviz ? pkgs.graphviz,
  gcSrc ? builtins.fetchGit ./. }:
stdenv.mkDerivation {
  name = "grahamc.com";
  buildInputs = [ jekyll graphviz ];
  src = gcSrc;

  shellHook = ''
    renderPhase() { eval "$renderPhase"; }
  '';

  renderPhase = ''
    find . -name '*.dot' -print0 | xargs -0 -n1 -P$NIX_BUILD_CORES ./render.sh
  '';

  buildPhase = ''
    eval "$renderPhase"
    rm -f result
    rm -rf ./_site
    jekyll build
  '';

  installPhase = ''
    mv _site $out
  '';

  testPhase = ''
    test -e $out/index.html
  '';
}
