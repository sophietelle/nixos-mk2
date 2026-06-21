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
      url = "github:mangowm/mango?tag=v0.12.9";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake/280a3440288256e54448221860fe89e82bfcfca0";
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
