#packages/packages.nix

pkgs: with pkgs; [
    # Editors and development
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    vscodium
    git
    gh
    gcc
    gnumake
    binutils
    cmake
    ninja
    pkg-config
    gdb

    # Languages
    python3
    swift
    swiftpm
    vala

    # Engines and simulation
    godot
    mujoco

    # Shell and terminal
    zsh
    ghostty
    wezterm
    pay-respects
    btop
    fastfetch

    # Command-line utilities
    wget
    curl
    aria2
    jq
    unzip
    openssl
    appimage-run

    # Security and keys
    gnupg
    seahorse
    howdy

    # Disks and storage
    ntfs3g
    baobab

    # Desktop (Pantheon and Wayland)
    pantheon-tweaks
    mako
    waybar
    fuzzel
    grim
    slurp
    wl-clipboard

    # Hardware
    surface-control

    # Phones and devices
    kdePackages.kdeconnect-kde
    usbmuxd
    libimobiledevice
    libusbmuxd
    libplist

    # Applications
    nicotine-plus
    gimp
    tsukimi

    # Games and education
    heroic
    prismlauncher
    supertux
    tuxpaint
    tuxtype

    # syd
    pfetch
]
