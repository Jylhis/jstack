# jstack library — skill discovery, manifest generation, and bundle building.
{ pkgs }:
let
  targets = import ./targets.nix;
  discoverSkills = import ./discover.nix;
  mkManifest = import ./manifest.nix { inherit pkgs; };
  mkBundle = import ./bundle.nix { inherit pkgs; };
in
{
  inherit
    targets
    discoverSkills
    mkManifest
    mkBundle
    ;
}
