# Windsurf tool module.
#
# Hybrid tool: MCP config is user-level (~/.codeium/windsurf/mcp_config.json),
# while rules and skills are project-level (.windsurf/).
# This module handles the user-level MCP config only.
# Project-level config is managed by modules/devenv.nix.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.programs.jstack;
  toolCfg = cfg.tools.windsurf;

  isHomeManager = options ? home.homeDirectory;
  isSystem = !isHomeManager;

  mcpFormat = import ../../lib/mcp-format.nix { inherit lib; };

  # Windsurf MCP config goes to ~/.codeium/windsurf/mcp_config.json
  mcpJson =
    if cfg.mcpServers != { } then
      pkgs.writeText "jstack-windsurf-mcp.json" (mcpFormat.formatMcpJson cfg.mcpServers)
    else
      null;

  generatedFiles = lib.optionalAttrs (mcpJson != null) {
    "${toolCfg.mcpConfigDir}/mcp_config.json" = mcpJson;
  };
in
{
  options.programs.jstack.tools.windsurf = {
    enable = lib.mkEnableOption "Windsurf configuration";

    mcpConfigDir = lib.mkOption {
      type = lib.types.str;
      default = ".codeium/windsurf";
      description = "Relative path (from HOME) for Windsurf's MCP config directory.";
    };

    extraInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text for .windsurfrules (deployed via devenv).";
    };
  };

  config = lib.mkIf (cfg.enable && toolCfg.enable) (
    lib.mkMerge (
      lib.optionals isHomeManager [
        {
          home.file = lib.mapAttrs (_: source: { inherit source; }) generatedFiles;
        }
      ]
      ++ lib.optionals isSystem [
        {
          programs.jstack._generated.windsurf.files = generatedFiles;
        }
      ]
    )
  );
}
