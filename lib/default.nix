# jstack library — skill discovery, manifest generation, and bundle building.
{ pkgs }:
let
  inherit (pkgs) lib;

  # v1 (legacy)
  targets = import ./targets.nix { inherit lib; };
  discoverSkills = import ./discover.nix;
  mkManifest = import ./manifest.nix { inherit pkgs; };
  mkBundle = import ./bundle.nix { inherit pkgs; };

  # v2
  toolDefs = import ./tool-defs.nix { inherit lib; };
  toolMappings = import ./tool-mappings.nix;
  mcpFormat = import ./mcp-format.nix { inherit lib; };
  instructionGen = import ./instruction-gen.nix { inherit lib; };
  skillBundle = import ./skill-bundle.nix { inherit pkgs lib; };
  defaultSkills = import ./default-skills.nix;
  compatibility = import ./compatibility-matrix.nix { inherit lib pkgs; };
in
{
  inherit
    # v1
    targets
    discoverSkills
    mkManifest
    mkBundle
    # v2
    toolDefs
    toolMappings
    mcpFormat
    instructionGen
    skillBundle
    defaultSkills
    compatibility
    ;
}
