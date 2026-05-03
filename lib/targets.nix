# Agent target definitions — derived from compatibility matrix.
{ lib ? import <nixpkgs/lib> { } }:
let
  compat = import ./compatibility-matrix.nix { inherit lib; };
  m = compat.matrix;
in
{
  claude = {
    name = "Claude Code";
    configDirDefault = "$HOME/.claude";
    configDirEnv = "CLAUDE_CONFIG_DIR";
    skillsSubdir = "skills";
    pluginsSubdir = "plugins";
    instructionsFile = builtins.baseNameOf m."claude-code".paths.instructions;
    manifestPath = m."claude-code".capabilities.manifest.file;
    mcpConfigFile = m."claude-code".capabilities.mcp.file;
    lspConfigFile = m."claude-code".capabilities.lsp.file;
  };

  codex = {
    name = "Codex";
    configDirDefault = "$HOME/.codex";
    configDirEnv = "CODEX_HOME";
    skillsSubdir = "skills";
    pluginsSubdir = null;
    instructionsFile = builtins.baseNameOf m.codex.paths.instructions;
    manifestPath = m.codex.capabilities.manifest.file;
    mcpConfigFile = m.codex.capabilities.mcp.file;
    lspConfigFile = m.codex.capabilities.lsp.file;
  };

  gemini = {
    name = "Gemini CLI";
    configDirDefault = "$HOME/.gemini";
    configDirEnv = null;
    skillsSubdir = "skills";
    pluginsSubdir = "extensions";
    instructionsFile = builtins.baseNameOf m.gemini.paths.instructions;
    manifestPath = m.gemini.capabilities.manifest.file;
    mcpConfigFile = m.gemini.capabilities.mcp.file;
    lspConfigFile = m.gemini.capabilities.lsp.file;
  };
}
