{ lib
, stdenvNoCC
, gtk3
, src
}:

stdenvNoCC.mkDerivation {
  pname = "elementary-urutau";
  version = "1.0";
  inherit src;

  nativeBuildInputs = [ gtk3 ];

  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons/elementary-urutau"
    cp -a "$src/." "$out/share/icons/elementary-urutau/"

    chmod -R u+rwX "$out/share/icons/elementary-urutau"

    # Fail the build if the theme metadata is missing.
    test -f "$out/share/icons/elementary-urutau/index.theme"

    # Generate the cache from the packaged theme.
    gtk-update-icon-cache -f \
      "$out/share/icons/elementary-urutau"

    runHook postInstall
  '';

  meta = {
    description = "Elementary icon theme with additional Urutau application icons";
    platforms = lib.platforms.linux;
  };
}
