{
  description = "Pacdef Nix module and derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs   = import nixpkgs { inherit system; };
      lib    = pkgs.lib;
    in {
      # Expose the derivation as a package output.
      packages = {
        pacdef = pkgs.callPackage ./pacdef-derivation.nix { };
      };

      # Expose the Home Manager module.
      # This module defines the options (config.program.pacdef) and activation code.
      modules = {
        pacdef = import ./module.nix {
          config = {};   # You can predefine defaults here if needed.
          pkgs   = pkgs;
          lib    = lib;
        };
      };

      # Optionally, you can define a defaultPackage for users of the flake.
      defaultPackage = self.packages.pacdef;
    };
}
