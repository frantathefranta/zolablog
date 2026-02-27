{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell {
  buildInputs = [
    zola
  ];

  shellHook = ''
    ${pkgs.git} submodule update --init --recursive
  '';
}
