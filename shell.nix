{ pkgs ? import <nixpkgs> {} }:

let
  radion-theme = builtins.fetchTarball {
    name = "radion";
    url = "https://github.com/frantathefranta/radion/archive/063cc74.tar.gz";
    sha256 = "1ci71qfpmwn1hzgx75qsdmnykhabkr3lrv9rrpam0pq6q00bgl8m";
  };
in

with pkgs;

mkShell {
  buildInputs = [
    zola
  ];

  shellHook = ''
    mkdir -p themes
    ln -snf "${radion-theme}" themes/radion
  '';
}
