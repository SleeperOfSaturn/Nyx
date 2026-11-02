{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      inter
      jetbrains-mono
      hack-font
    ];

    fontconfig = {
      enable = true;
      antialias = true;

      # never fall back to jagged legacy bitmap fonts
      allowBitmaps = false;

      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };

      subpixel = {
        rgba = "none";
      };
    };
  };
}
