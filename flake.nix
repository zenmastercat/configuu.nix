{
  description = "NixOS Flake Configuration and Home-manager";

  inputs = {
    # Unstable Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home-manager (Tracking master to match nixos-unstable)
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-ros-overlay 
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
  };

  outputs = { self, nixpkgs, home-manager, nix-ros-overlay, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; };
    in {
      # NixOS System Configuration
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Inject the overlay into nixpkgs
          {
            nixpkgs.overlays = [
              nix-ros-overlay.overlays.default
              (final: prev: {
                libfyaml = prev.libfyaml.overrideAttrs (oldAttrs: {
                  patches = prev.lib.unique (oldAttrs.patches or [ ]);
                });
              })
            ];
          }
          ./hardware-configuration.nix
          ./configuration.nix
          ./applications.nix
        ];
      };

      # Home Manager Configuration
      homeConfigurations.myprofile = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
