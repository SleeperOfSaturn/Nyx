{ config, pkgs, inputs, ... }:

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
    ] ++ [
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
      inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
    ];

    fontconfig = {
      enable = true;
      antialias = true;

      allowBitmaps = false;

      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };

      subpixel = {
        rgba = "none";
      };

      defaultFonts = {
        sansSerif = [
          "SFProDisplay Nerd Font"
          "Noto Color Emoji"
        ];

        serif = [
          "SFProDisplay Nerd Font"
        ];

        monospace = [
          "SFMono Nerd Font"
        ];

        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };
}
