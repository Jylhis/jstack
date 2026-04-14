# Aider tool module.
#
# Project-level tool: CONVENTIONS.md and .aider.conf.yml live in project directory.
# No MCP support. Deployment happens via modules/devenv.nix.
# This module only declares options.
{ lib, ... }:
{
  options.programs.jstack.tools.aider = {
    enable = lib.mkEnableOption "Aider configuration";

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "Extra fields merged into .aider.conf.yml.";
    };

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text for CONVENTIONS.md.";
    };
  };
}
