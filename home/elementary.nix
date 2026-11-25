{ pkgs, ... }:

let
  elementary = pkgs.pantheon.elementary-gtk-theme;
  variant = "blueberry";
  themeName = "io.elementary.stylesheet.${variant}";
in
{
  gtk = {
    enable = true;

    theme = {
      name = themeName;
      package = elementary;
    };

    gtk4 = {
      enable = true;

      theme = {
        name = themeName;
        package = elementary;
      };
    };
  };
}
