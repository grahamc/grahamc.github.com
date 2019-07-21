let
  pkgs = import <nixpkgs> {};

  asciinema-css = pkgs.fetchurl {
    url = "https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.css";
    sha256 = "sha256:1yi45fdps5mjqdwjhqwwzvlwxb4j7fb8451z7s6sdqmi7py8dksj";
  };
  asciinema-js = pkgs.fetchurl {
    url = "https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.js";
    sha256 = "sha256:092y2zl51z23jrl6mcqfxb64xaf9f2dx0j8kp69hp07m0935cz2p";
  };

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

  resourcesPhase = ''
    #cp ${asciinema-css} ./asciinema.css
    cp ./asci-cust.css ./asciinema.css
    cp ${asciinema-js} ./asciinema.js
  '';

  renderPhase = ''
    find . -name '*.dot' -print0 | xargs -0 -n1 -P$NIX_BUILD_CORES ./render.sh
  '';

  buildPhase = ''
    eval "$resourcesPhase"
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
