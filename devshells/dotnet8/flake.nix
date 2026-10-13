{
  description = "dotnet 8 runtime overlay (net8.0 projects, layered onto the global dotnet-10 mutable root)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      mutableRoot = "$HOME/.local/dotnet-10"; # must match config/dotnet-tools
      runtime = pkgs.dotnet-aspnetcore_8;
    in
    {
      devShells.${system}.default =
        pkgs.mkShell {
          shellHook = ''
            cp -rn ${runtime}/share/dotnet/. "${mutableRoot}/share/dotnet/" 2>/dev/null || true
            chmod -R u+w "${mutableRoot}/share/dotnet" 2>/dev/null || true
            echo "================================================================="
            echo " dotnet8 runtime layered onto global SDK"
            echo "================================================================="
          '';
        };
    };
}
