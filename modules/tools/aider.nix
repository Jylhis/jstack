# Aider tool module.
#
# Project-level tool: CONVENTIONS.md and .aider.conf.yml live in project directory.
# No MCP support. Deployment happens via modules/devenv.nix.
# This module only declares options.
{
  config,
  lib,
  options,
  ...
}:

let
  # Upstream Home Manager module is `programs.aider-chat` (hyphenated).
  hasUpstream = lib.hasAttrByPath [ "programs" "aider-chat" "enable" ] options;
in
{
  options.programs.jstack.tools.aider = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = if hasUpstream then config.programs.aider-chat.enable else false;
      defaultText = lib.literalExpression ''
        if the upstream Home Manager `programs.aider-chat` module is loaded,
        its `enable` value; otherwise `false`.
      '';
      example = true;
      description = ''
        Whether to enable Aider configuration.

        In Home Manager context, this defaults to the upstream
        `programs.aider-chat.enable` value when the upstream module is loaded.
      '';
    };

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
