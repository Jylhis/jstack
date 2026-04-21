# Gemini CLI tool module.
#
# User-level tool: config lives in ~/.gemini/.
# MCP config is embedded in settings.json under mcpServers key.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.programs.jstack;
  toolCfg = cfg.tools.gemini;

  isHomeManager = options ? home.homeDirectory;
  isSystem = !isHomeManager;

  # Upstream Home Manager module is `programs.gemini-cli` (hyphenated).
  hasUpstream = lib.hasAttrByPath [ "programs" "gemini-cli" "enable" ] options;

  mcpFormat = import ../../lib/mcp-format.nix { inherit lib; };
  instructionGen = import ../../lib/instruction-gen.nix { inherit lib; };
  skillBundle = import ../../lib/skill-bundle.nix { inherit pkgs lib; };

  toolSkills = lib.filterAttrs (
    _: skill: skill.tools == null || builtins.elem "gemini" skill.tools
  ) cfg._resolvedSkills;

  skills =
    if toolSkills != { } then
      skillBundle.mkSkillBundle {
        skills = toolSkills;
        toolName = "gemini";
      }
    else
      null;

  instructionContent = instructionGen.mkInstructionFile {
    shared = cfg.instructions;
    extra = toolCfg.extraInstructions;
  };

  instructionFile =
    if instructionContent != "" then pkgs.writeText "GEMINI.md" instructionContent else null;

  # Gemini settings.json with embedded MCP servers
  mergedSettings =
    { }
    // lib.optionalAttrs (cfg.mcpServers != { }) {
      mcpServers = mcpFormat.formatMcpAttrs cfg.mcpServers;
    }
    // toolCfg.settings;

  settingsFile =
    if mergedSettings != { } then
      pkgs.writeText "jstack-gemini-settings.json" (builtins.toJSON mergedSettings)
    else
      null;

  generatedFiles =
    { }
    // lib.optionalAttrs (instructionFile != null) {
      ".gemini/GEMINI.md" = instructionFile;
    }
    // lib.optionalAttrs (settingsFile != null) {
      ".gemini/settings.json" = settingsFile;
    };
in
{
  options.programs.jstack.tools.gemini = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = if hasUpstream then config.programs.gemini-cli.enable else false;
      defaultText = lib.literalExpression ''
        if the upstream Home Manager `programs.gemini-cli` module is loaded,
        its `enable` value; otherwise `false`.
      '';
      example = true;
      description = ''
        Whether to enable Gemini CLI configuration.

        In Home Manager context, this defaults to the upstream
        `programs.gemini-cli.enable` value when the upstream module is loaded.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "Extra fields merged into settings.json.";
    };

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text appended to GEMINI.md.";
    };
  };

  config = lib.mkIf (cfg.enable && toolCfg.enable) (
    lib.mkMerge (
      lib.optionals isHomeManager [
        {
          home.file = lib.mapAttrs (_: source: { inherit source; }) generatedFiles;
        }
        (lib.mkIf (skills != null) {
          home.file.".gemini/skills".source = skills;
        })
      ]
      ++ lib.optionals isSystem [
        {
          programs.jstack._generated.gemini.files = generatedFiles;
        }
        (lib.mkIf (skills != null) {
          programs.jstack._generated.gemini.dirs = {
            ".gemini/skills" = skills;
          };
        })
      ]
    )
  );
}
