{
  pkgs ? import (import ./npins).nixpkgs { overlays = [ (import ./overlay.nix) ]; },
  lib ? pkgs.lib,
}:
{
  packages.default = pkgs.jstack-runtime;
  overlays.default = import ./overlay.nix;
  nixosModules.default = import ./module.nix;
  darwinModules.default = import ./module.nix;
  homeModules.default = import ./module.nix;
  lib = import ./lib { inherit pkgs; };
}
