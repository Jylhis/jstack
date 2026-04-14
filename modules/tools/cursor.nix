# Cursor tool module.
#
# Project-level tool: config lives in .cursor/ (project directory).
# Deployment happens via modules/devenv.nix, not via the system module.
# This module only declares options.
{ lib, ... }:
{
  options.programs.jstack.tools.cursor = {
    enable = lib.mkEnableOption "Cursor configuration";

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text for .cursor/rules/jstack.md.";
    };
  };
}
