{
  description = "jstack - multi-agent AI developer workflow configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      defaultOutputs = import ./default.nix { };
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      overlays = defaultOutputs.overlays;
      nixosModules = defaultOutputs.nixosModules;
      darwinModules = defaultOutputs.darwinModules;
      homeModules = defaultOutputs.homeModules;
      # packages and lib omitted — triggers impure pkgs evaluation in pure flake mode
      # Use `nix-build -A packages.default` instead

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          moduleEvalResult = import ./tests/module-eval.nix { inherit system; };
        in
        {
          module-eval = pkgs.runCommand "jstack-module-eval" { } ''
            echo ${moduleEvalResult} > $out
          '';
        }
      );
    };
}
