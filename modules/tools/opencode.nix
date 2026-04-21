# OpenCode tool module.
#
# Project-level tool: config lives in project directory (opencode.json).
# Deployment happens via modules/devenv.nix, not via the system module.
# This module only declares options.
{
  config,
  lib,
  options,
  ...
}:

let
  hasUpstream = lib.hasAttrByPath [ "programs" "opencode" "enable" ] options;
in
{
  options.programs.jstack.tools.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = if hasUpstream then config.programs.opencode.enable else false;
      defaultText = lib.literalExpression ''
        if the upstream Home Manager `programs.opencode` module is loaded,
        its `enable` value; otherwise `false`.
      '';
      example = true;
      description = ''
        Whether to enable OpenCode configuration.

        In Home Manager context, this defaults to the upstream
        `programs.opencode.enable` value when the upstream module is loaded.
      '';
    };

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
