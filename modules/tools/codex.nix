# Codex CLI tool module.
#
# User-level tool: config lives in ~/.codex/.
# MCP config is TOML format (config.toml [mcp_servers] section).
{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.programs.jstack;
  toolCfg = cfg.tools.codex;

  isHomeManager = options ? home.homeDirectory;
  isSystem = !isHomeManager;

  hasUpstream = lib.hasAttrByPath [ "programs" "codex" "enable" ] options;

  mcpFormat = import ../../lib/mcp-format.nix { inherit lib; };
  instructionGen = import ../../lib/instruction-gen.nix { inherit lib; };
  skillBundle = import ../../lib/skill-bundle.nix { inherit pkgs lib; };

  toolSkills = lib.filterAttrs (
    _: skill: skill.tools == null || builtins.elem "codex" skill.tools
  ) cfg._resolvedSkills;

  skills =
    if toolSkills != { } then
      skillBundle.mkSkillBundle {
        skills = toolSkills;
        toolName = "codex";
      }
    else
      null;

  instructionContent = instructionGen.mkInstructionFile {
    shared = cfg.instructions;
    extra = toolCfg.extraInstructions;
  };

  instructionFile =
    if instructionContent != "" then pkgs.writeText "AGENTS.md" instructionContent else null;

  # Codex config.toml with MCP servers (TOML format via remarshal)
  configToml = if cfg.mcpServers != { } then mcpFormat.formatMcpToml pkgs cfg.mcpServers else null;

  generatedFiles =
    { }
    // lib.optionalAttrs (instructionFile != null) {
      ".codex/AGENTS.md" = instructionFile;
    }
    // lib.optionalAttrs (configToml != null) {
      ".codex/config.toml" = configToml;
    };
in
{
  options.programs.jstack.tools.codex = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = if hasUpstream then config.programs.codex.enable else false;
      defaultText = lib.literalExpression ''
        if the upstream Home Manager `programs.codex` module is loaded,
        its `enable` value; otherwise `false`.
      '';
      example = true;
      description = ''
        Whether to enable Codex CLI configuration.

        In Home Manager context, this defaults to the upstream
        `programs.codex.enable` value when the upstream module is loaded.
      '';
    };

    sandboxMode = lib.mkOption {
      type = lib.types.enum [
        "workspace-write"
        "workspace-read"
        "full-auto"
      ];
      default = "workspace-write";
      description = "Codex sandbox mode.";
    };

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
          home.file.".codex/skills".source = skills;
        })
      ]
      ++ lib.optionals isSystem [
        {
          programs.jstack._generated.codex.files = generatedFiles;
        }
        (lib.mkIf (skills != null) {
          programs.jstack._generated.codex.dirs = {
            ".codex/skills" = skills;
          };
        })
      ]
    )
  );
}
