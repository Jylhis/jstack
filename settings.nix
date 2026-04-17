{
  "$schema" = "https://json.schemastore.org/claude-code-settings.json";
  env.CLAUDE_CODE_EFFORT_LEVEL = "high";
  includeCoAuthoredBy = false;
  permissions.allow = [
    "Read"
    "Grep"
    "Glob"
    "WebSearch"
    "WebFetch"
    "mcp__fetch__fetch"
  ];
  hooks = {
    PreToolUse = [
      {
        matcher = "Edit|Write";
        hooks = [
          {
            type = "command";
            command = ''"$CLAUDE_PROJECT_DIR"/hooks/protect-generated-files.sh'';
          }
        ];
      }
    ];
    PostToolUse = [
      {
        matcher = "Edit|Write";
        hooks = [
          {
            type = "command";
            command = ''"$CLAUDE_PROJECT_DIR"/hooks/auto-format.sh'';
          }
        ];
      }
    ];
  };
  model = "opus[1m]";
  statusLine = {
    type = "command";
    command = "wt list statusline --format=claude-code";
  };
  spinnerTipsEnabled = false;
  alwaysThinkingEnabled = true;
  effortLevel = "high";
  extraKnownMarketplaces = {
    jstack = {
      source = {
        source = "github";
        repo = "Jylhis/jstack";
      };
    };
  };
}
