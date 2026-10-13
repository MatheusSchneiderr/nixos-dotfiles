{
  description = "schneider's NixOS config";
  # llama-cpp-sycl (pkgs/llama-cpp-sycl.nix) is built from source, in-repo,
  # rather than as a separate cached repo - the icpx/SYCL compile step was
  # confirmed non-reproducible (Nix's determinism checker caught a rebuild
  # producing different, non-functional output from identical inputs), so
  # only building it here, where every rebuild has been verified, is trusted.
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    aspire = {
      url = "github:microsoft/aspire";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, plasma-manager, aspire, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.laptop-schneider = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/laptop-schneider/configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.schneider = import ./hosts/laptop-schneider/home.nix;
              backupFileExtension = "backup";
              sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              extraSpecialArgs = { inherit aspire; };
            };
          }
        ];
      };
    };
}
