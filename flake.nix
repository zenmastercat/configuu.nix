{
  description = "NixOS Flake Configuration";

  inputs = {
    # Unstable Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nix-ros-overlay 
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
  };

  outputs = { self, nixpkgs, nix-ros-overlay, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        # Inject the overlay into nixpkgs
        {
          nixpkgs.overlays = [ nix-ros-overlay.overlays.default ];
        }
        ./hardware-configuration.nix
        ./configuration.nix
        ./applications.nix
      ];
    };
  };
}
