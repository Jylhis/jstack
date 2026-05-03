# Tool definitions — canonical paths and formats per AI coding agent.
{ lib ? import <nixpkgs/lib> { } }:
let
  compat = import ./compatibility-matrix.nix { inherit lib; };
  m = compat.matrix;
in
{
  claude-code = {
    name = "Claude Code";
    level = m."claude-code".level;
    configDir = m."claude-code".paths.configDir;
    skillsSubdir = "skills";
    instructionsFile = m."claude-code".paths.instructions;
    mcpConfigFile = m."claude-code".capabilities.mcp.file;
    mcpFormat = "json";
    settingsFile = ".claude/settings.json";
    settingsFormat = "json";
  };

  codex = {
    name = "Codex CLI";
    level = m.codex.level;
    configDir = m.codex.paths.configDir;
    configDirEnv = "CODEX_HOME";
    skillsSubdir = "skills";
    instructionsFile = m.codex.paths.instructions;
    mcpConfigFile = m.codex.capabilities.mcp.file;
    mcpFormat = "toml";
    settingsFile = ".codex/config.toml";
    settingsFormat = "toml";
  };

  gemini = {
    name = "Gemini CLI";
    level = m.gemini.level;
    configDir = m.gemini.paths.configDir;
    skillsSubdir = "skills";
    instructionsFile = m.gemini.paths.instructions;
    mcpConfigFile = m.gemini.capabilities.mcp.file;
    mcpFormat = "embedded-json";
    settingsFile = ".gemini/settings.json";
    settingsFormat = "json";
  };
}
