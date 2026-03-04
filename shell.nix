{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell {
  strictDeps = true;
  nativeBuildInputs = [
    zola
    taplo
    yaml-language-server
  ];

  shellHook = ''
    ${pkgs.git}/bin/git submodule update --init --recursive
  '';
}
