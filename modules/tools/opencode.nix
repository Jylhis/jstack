# OpenCode tool module.
#
# Project-level tool: config lives in project directory (opencode.json).
# Deployment happens via modules/devenv.nix, not via the system module.
# This module only declares options.
{ lib, ... }:
{
  options.programs.jstack.tools.opencode = {
    enable = lib.mkEnableOption "OpenCode configuration";

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "Extra fields merged into opencode.json.";
    };

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text appended to AGENTS.md.";
    };
  };
}
