# Convenience expression for listing all discovered skills.
# Usage: nix eval --impure --json --expr 'import ./lib/list-catalog.nix' | jq .
let
  flakeSources = import ../_sources.nix;
  pkgs = import flakeSources.nixpkgs { };
  discoverSkills = import ./discover.nix;

  # Discover skills from flat skills/ directory
  localCatalog = discoverSkills {
    path = ../skills;
    namespace = "jstack";
  };

  # Discover third-party skills from flake inputs
  thirdPartySources = import ../sources.nix;
  thirdPartyCatalogs = pkgs.lib.mapAttrsToList (
    pinName: opts:
    discoverSkills {
      path = flakeSources.${pinName} + "/${opts.skillsRoot or "."}";
      namespace = opts.namespace;
      maxDepth = opts.maxDepth or 5;
    }
  ) thirdPartySources;

  allCatalogs = [ localCatalog ] ++ thirdPartyCatalogs;
  merged = builtins.foldl' (a: b: a // b) { } allCatalogs;
in
builtins.mapAttrs (_: s: {
  inherit (s) name namespace relativePath;
}) merged
