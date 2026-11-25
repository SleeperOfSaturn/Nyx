{
  description = "Saturn's flake";

  inputs = {

    # Standard nixpkgs definition
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # NixOS hardware definition
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Package Management
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    syd.url = "github:sidharthify/syd";
    pkgit = {
      url = "git+https://git.symlinx.net/pkgit";
      flake = false;
    };

    # Application Packages
    durdraw.url = "github:Daaboulex/durdraw-nix";
    helium-browser.url = "github:AlvaroParker/helium-nix";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    blueferry.url = "github:piercegwang/nix-flake-blueferry";
    blip.url = "github:blip-net/nix";

    # Miscellaneous Packages
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sunshine-virt-display = {
      url = "github:frostplexx/sunshine_virt_display";
      flake = false;
    };

    # Configurator Packages
    lazyvim-nix.url = "github:pfassina/lazyvim-nix";
    nixcord.url = "github:4evy/nixcord";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-master,
    home-manager,
    lazyvim-nix,
    nix-flatpak,
    ...
  } @ inputs: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./nixos/configuration.nix

        inputs.nixos-hardware.nixosModules.microsoft-surface-common
        nix-flatpak.nixosModules.nix-flatpak
        inputs.blueferry.nixosModules.default
        home-manager.nixosModules.home-manager

        # Master package set, available as pkgs.master
        {
          nixpkgs.overlays = [
            (final: prev: {
              master = import nixpkgs-master {
                inherit (final) system config;
              };
            })
          ];
        }

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";

          home-manager.users.saturn.imports = [
            ./home/home.nix
            lazyvim-nix.homeManagerModules.default
          ];

          home-manager.sharedModules = [
            inputs.nixcord.homeModules.nixcord
          ];

          home-manager.extraSpecialArgs = {
            inherit lazyvim-nix inputs;
          };
        }
      ];
    };
  };
}
