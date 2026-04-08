# Agent target definitions — paths, formats, and conventions per AI coding agent.
# Pure data, no pkgs needed.
{
  claude = {
    name = "Claude Code";
    configDirDefault = "$HOME/.claude";
    configDirEnv = "CLAUDE_CONFIG_DIR";
    skillsSubdir = "skills";
    pluginsSubdir = "plugins";
    instructionsFile = "CLAUDE.md";
    manifestPath = ".claude-plugin/plugin.json";
    mcpConfigFile = ".mcp.json";
    lspConfigFile = ".lsp.json";
  };

  codex = {
    name = "Codex";
    configDirDefault = "$HOME/.codex";
    configDirEnv = "CODEX_HOME";
    skillsSubdir = "skills";
    pluginsSubdir = null;
    instructionsFile = "AGENTS.md";
    manifestPath = null;
    mcpConfigFile = null;
    lspConfigFile = null;
  };

  gemini = {
    name = "Gemini CLI";
    configDirDefault = "$HOME/.gemini";
    configDirEnv = null;
    skillsSubdir = "skills";
    pluginsSubdir = "extensions";
    instructionsFile = "GEMINI.md";
    manifestPath = "gemini-extension.json";
    mcpConfigFile = null;
    lspConfigFile = null;
  };
}
