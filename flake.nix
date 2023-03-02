{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = self.packages.x86_64-linux.default;

      packages.x86_64-linux = {
        asciinema-css = pkgs.fetchurl {
          url = "https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.css";
          sha256 = "sha256:1yi45fdps5mjqdwjhqwwzvlwxb4j7fb8451z7s6sdqmi7py8dksj";
        };
        asciinema-js = pkgs.fetchurl {
          url = "https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.js";
          sha256 = "sha256:092y2zl51z23jrl6mcqfxb64xaf9f2dx0j8kp69hp07m0935cz2p";
        };

        default = pkgs.stdenv.mkDerivation {
          name = "grahamc.com";
          buildInputs = with pkgs; [ jekyll graphviz flyctl skopeo ];
          src = self;

          shellHook = ''
            renderPhase() { eval "$renderPhase"; }
          '';

          renderPhase = ''
            find . -name '*.dot' -print0 | xargs -0 -n1 -P$NIX_BUILD_CORES ./render.sh
          '';

          buildPhase = ''
            patchShebangs ./render.sh
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
        ;
      };

      dockerImages.x86_64-linux.default = pkgs.dockerTools.buildLayeredImage {
        name = "grahamc.com";
        config = {
          ExposedPorts."8080/tcp" = { };
          Cmd = [
            "${pkgs.static-web-server}/bin/static-web-server"
            "--ignore-hidden-files"
          ]
          ++ [ "--port" "8080" ]
          ++ [ "--log-level" "info" ]
          ++ [ "--root" "${self.packages.x86_64-linux.default}" ]
          ;
        };
      };
    };
}
