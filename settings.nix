{
  "$schema" = "https://json.schemastore.org/claude-code-settings.json";
  includeCoAuthoredBy = false;
  permissions.allow = [
    "Read"
    "Grep"
    "Glob"
    "WebSearch"
    "WebFetch"
    "mcp__fetch__fetch"
  ];
  statusLine = {
    type = "command";
    command = "wt list statusline --format=claude-code";
  };
  spinnerTipsEnabled = false;
  alwaysThinkingEnabled = true;
  extraKnownMarketplaces = {
    jstack = {
      source = {
        source = "github";
        repo = "Jylhis/jstack";
      };
    };
  };
}
