# Abstract tool name mappings — per-agent concrete tool names.
#
# Skills use {{tools.<operation>}} placeholders in SKILL.md frontmatter
# (e.g., `allowed-tools: {{tools.read}} {{tools.edit}} {{tools.bash}}`).
# The skill bundler replaces these with concrete names per target tool.
#
# A value of `null` means the tool does not support that operation.
# The bundler replaces null-mapped placeholders with "(not available)".
#
# Source: research/cross-tool-comparison.md
#
# Pure data, no pkgs needed.
{
  read = {
    claude-code = "Read";
    codex = "read_file";
    gemini = "read_file";
    opencode = "read";
    pi = "read";
    cursor = null;
    windsurf = null;
    cline = "read_file";
    aider = null;
  };

  write = {
    claude-code = "Write";
    codex = "write_file";
    gemini = "write_file";
    opencode = "write";
    pi = "write";
    cursor = null;
    windsurf = null;
    cline = "write_to_file";
    aider = null;
  };

  edit = {
    claude-code = "Edit";
    codex = "apply_patch";
    gemini = "replace";
    opencode = "edit";
    pi = "edit";
    cursor = null;
    windsurf = null;
    cline = "replace_in_file";
    aider = null;
  };

  bash = {
    claude-code = "Bash";
    codex = "shell";
    gemini = "run_shell_command";
    opencode = "bash";
    pi = "bash";
    cursor = null;
    windsurf = null;
    cline = "execute_command";
    aider = null;
  };

  glob = {
    claude-code = "Glob";
    codex = "search";
    gemini = "glob";
    opencode = "glob";
    pi = null;
    cursor = null;
    windsurf = null;
    cline = "list_files";
    aider = null;
  };

  grep = {
    claude-code = "Grep";
    codex = "search";
    gemini = "grep_search";
    opencode = "grep";
    pi = null;
    cursor = null;
    windsurf = null;
    cline = "search_files";
    aider = null;
  };

  askUser = {
    claude-code = "AskUserQuestion";
    codex = null;
    gemini = "ask_user";
    opencode = "question";
    pi = null;
    cursor = null;
    windsurf = null;
    cline = "ask_followup_question";
    aider = null;
  };

  webFetch = {
    claude-code = "WebFetch";
    codex = "web_search";
    gemini = "web_fetch";
    opencode = "webfetch";
    pi = null;
    cursor = null;
    windsurf = null;
    cline = null;
    aider = null;
  };

  webSearch = {
    claude-code = "WebSearch";
    codex = "web_search";
    gemini = "google_web_search";
    opencode = "websearch";
    pi = null;
    cursor = null;
    windsurf = null;
    cline = null;
    aider = null;
  };
}
