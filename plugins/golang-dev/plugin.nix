{ pkgs }:
{
  name = "golang-dev";
  version = "0.3.0";
  description = "Go development intelligence: 36 skills covering idioms, patterns, testing, performance, security, and modern syntax (Go 1.21-1.26) plus gopls LSP and built-in gopls MCP server";
  author.name = "Markus Jylhänkangas";

  packages = [ pkgs.gopls ];

  lspServers = {
    go = {
      command = "gopls";
      args = [ "serve" ];
      extensionToLanguage = {
        ".go" = "go";
      };
    };
  };

  # gopls ships a built-in MCP server since v0.20. `gopls mcp` starts it
  # over stdio with no flags. Exposes go_diagnostics, go_references,
  # go_rename_symbol, go_search, go_vulncheck, go_workspace, go_file_context.
  mcpServers = {
    gopls = {
      type = "stdio";
      command = "gopls";
      args = [ "mcp" ];
    };
  };
}
