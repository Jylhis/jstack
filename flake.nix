{
  description = "jstack - multi-agent AI developer workflow configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      defaultOutputs = import ./default.nix { };
    in
    {
      overlays = defaultOutputs.overlays;
      nixosModules = defaultOutputs.nixosModules;
      darwinModules = defaultOutputs.darwinModules;
      homeModules = defaultOutputs.homeModules;
      # packages and lib omitted — triggers impure pkgs evaluation in pure flake mode
      # Use `nix-build -A packages.default` instead
    };
}
