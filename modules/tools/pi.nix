# Pi tool module.
#
# User-level tool: config lives in ~/.pi/.
# MCP config is standalone JSON (.pi/mcp.json).
{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.programs.jstack;
  toolCfg = cfg.tools.pi;

  isHomeManager = options ? home.homeDirectory;
  isSystem = !isHomeManager;

  mcpFormat = import ../../lib/mcp-format.nix { inherit lib; };
  instructionGen = import ../../lib/instruction-gen.nix { inherit lib; };
  skillBundle = import ../../lib/skill-bundle.nix { inherit pkgs lib; };

  toolSkills = lib.filterAttrs (
    _: skill: skill.tools == null || builtins.elem "pi" skill.tools
  ) cfg._resolvedSkills;

  skills =
    if toolSkills != { } then
      skillBundle.mkSkillBundle {
        skills = toolSkills;
        toolName = "pi";
      }
    else
      null;

  instructionContent = instructionGen.mkInstructionFile {
    shared = cfg.instructions;
    extra = toolCfg.extraInstructions;
  };

  instructionFile =
    if instructionContent != "" then pkgs.writeText "AGENTS.md" instructionContent else null;

  mcpJson =
    if cfg.mcpServers != { } then
      pkgs.writeText "jstack-pi-mcp.json" (mcpFormat.formatMcpJson cfg.mcpServers)
    else
      null;

  generatedFiles =
    { }
    // lib.optionalAttrs (instructionFile != null) { ".pi/AGENTS.md" = instructionFile; }
    // lib.optionalAttrs (mcpJson != null) { ".pi/mcp.json" = mcpJson; };
in
{
  options.programs.jstack.tools.pi = {
    enable = lib.mkEnableOption "Pi configuration";

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text appended to AGENTS.md.";
    };
  };

  config = lib.mkIf (cfg.enable && toolCfg.enable) (
    lib.mkMerge (
      lib.optionals isHomeManager [
        {
          home.file = lib.mapAttrs (_: source: { inherit source; }) generatedFiles;
        }
        (lib.mkIf (skills != null) {
          home.file.".pi/skills".source = skills;
        })
      ]
      ++ lib.optionals isSystem [
        {
          programs.jstack._generated.pi.files = generatedFiles;
        }
        (lib.mkIf (skills != null) {
          programs.jstack._generated.pi.dirs = {
            ".pi/skills" = skills;
          };
        })
      ]
    )
  );
}
