# Cline tool module.
#
# Project-level tool: instructions live in .clinerules/ (project directory).
# MCP config lives in VS Code extension dir (not auto-managed).
# Deployment happens via modules/devenv.nix, not via the system module.
# This module only declares options.
{ lib, ... }:
{
  options.programs.jstack.tools.cline = {
    enable = lib.mkEnableOption "Cline configuration";

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text for .clinerules/jstack.md.";
    };
  };
}
