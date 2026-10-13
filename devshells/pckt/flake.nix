{


  description = "fhs devshell for cisco packter tracer";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  
  outputs = { self , nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = [ pkgs.ciscoPacketTracer9 ];
    };
  };
  
  
}
