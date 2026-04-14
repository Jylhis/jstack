# Tool definitions — paths, formats, and conventions per AI coding agent.
#
# Each tool is classified as "user" (config in $HOME, managed by NixOS/HM/nix-darwin)
# or "project" (config in project dir, managed by devenv or manual setup).
# Some tools have both user-level and project-level config.
#
# Pure data, no pkgs needed.
{
  claude-code = {
    name = "Claude Code";
    level = "user";
    configDir = ".claude";
    configDirEnv = "CLAUDE_CONFIG_DIR";
    skillsSubdir = "skills";
    instructionsFile = "CLAUDE.md";
    mcpConfigFile = ".mcp.json";
    mcpFormat = "json"; # { mcpServers: { name: { command, args, env } } }
    settingsFile = ".claude/settings.json";
    settingsFormat = "json";
  };

  codex = {
    name = "Codex CLI";
    level = "user";
    configDir = ".codex";
    configDirEnv = "CODEX_HOME";
    skillsSubdir = "skills";
    instructionsFile = "AGENTS.md";
    mcpConfigFile = ".codex/config.toml";
    mcpFormat = "toml"; # [mcp_servers.name] command = "..." args = [...]
    settingsFile = ".codex/config.toml";
    settingsFormat = "toml";
  };

  gemini = {
    name = "Gemini CLI";
    level = "user";
    configDir = ".gemini";
    configDirEnv = null;
    skillsSubdir = "skills";
    instructionsFile = "GEMINI.md";
    mcpConfigFile = ".gemini/settings.json";
    mcpFormat = "embedded-json"; # mcpServers key inside settings.json
    settingsFile = ".gemini/settings.json";
    settingsFormat = "json";
  };

  pi = {
    name = "Pi";
    level = "user";
    configDir = ".pi";
    configDirEnv = null;
    skillsSubdir = "skills";
    instructionsFile = "AGENTS.md";
    mcpConfigFile = ".pi/mcp.json";
    mcpFormat = "json";
    settingsFile = ".pi/settings.json";
    settingsFormat = "json";
  };

  windsurf = {
    name = "Windsurf";
    level = "both"; # MCP is user-level, rules/skills are project-level
    # User-level (MCP config)
    userMcpConfigFile = ".codeium/windsurf/mcp_config.json";
    userMcpFormat = "json";
    # Project-level (rules, skills)
    configDir = ".windsurf";
    skillsSubdir = "skills";
    instructionsFile = ".windsurfrules";
    settingsFile = null;
    settingsFormat = null;
  };

  cursor = {
    name = "Cursor";
    level = "project";
    configDir = ".cursor";
    skillsSubdir = "skills";
    instructionsFile = ".cursor/rules/jstack.md";
    mcpConfigFile = ".cursor/mcp.json";
    mcpFormat = "json";
    settingsFile = null;
    settingsFormat = null;
  };

  opencode = {
    name = "OpenCode";
    level = "project";
    configDir = ".opencode";
    skillsSubdir = "skills";
    instructionsFile = "AGENTS.md";
    mcpConfigFile = "opencode.json";
    mcpFormat = "embedded-json"; # mcp key inside opencode.json
    settingsFile = "opencode.json";
    settingsFormat = "json";
  };

  cline = {
    name = "Cline";
    level = "project";
    configDir = null; # VS Code extension, no simple config dir
    skillsSubdir = null; # No skill discovery
    instructionsFile = ".clinerules/jstack.md";
    mcpConfigFile = null; # Lives in VS Code ext dir, not manageable
    mcpFormat = null;
    settingsFile = null;
    settingsFormat = null;
  };

  aider = {
    name = "Aider";
    level = "project";
    configDir = null;
    skillsSubdir = null; # No skill discovery
    instructionsFile = "CONVENTIONS.md";
    mcpConfigFile = null; # No MCP support
    mcpFormat = null;
    settingsFile = ".aider.conf.yml";
    settingsFormat = "yaml";
  };
}
