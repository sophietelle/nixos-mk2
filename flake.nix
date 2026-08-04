{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango?tag=v0.14.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake/52e6bfd6e6b5eaab2e96095f7d936e5bf6a72f24";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ida-pro-overlay = {
      url = "github:msanft/ida-pro-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      laptop = (import ./laptop/laptop.nix { inherit nixpkgs inputs; });
    };
  };
}
