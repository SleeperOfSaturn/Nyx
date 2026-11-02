{ lib
, stdenv
, pkg-config
, luajit
, gnumake
, src
}:

stdenv.mkDerivation {
  pname = "pkgit";
  version = "unstable";

  inherit src;

  nativeBuildInputs = [
    pkg-config
    gnumake
  ];

  buildInputs = [
    luajit
  ];

  installPhase = ''
    runHook preInstall
    make install PREFIX="$out"
    runHook postInstall
  '';

  meta = {
    description = "A universal, system-agnostic package manager";
    homepage = "https://git.symlinx.net/pkgit";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
