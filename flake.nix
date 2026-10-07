{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango?tag=v0.17.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake/14a8f68137d4db62213555937f23ad95e7f8c4e6";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ida-pro-overlay = {
      url = "github:msanft/ida-pro-overlay/fae2e9edae8728e6b7b31e2542b774caa6c21e5f";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cshot = {
      url = "github:highc0de/cshot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
    extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      fa506icb = (import ./laptop/laptop.nix { inherit nixpkgs inputs; });
    };
  };
}
