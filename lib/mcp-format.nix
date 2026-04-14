# MCP config formatters — convert a shared mcpServers attrset to per-tool format.
#
# Each tool stores MCP server configuration differently:
#   - Claude Code, Cursor, Windsurf, Pi: standalone JSON file
#   - Codex CLI: TOML [mcp_servers] section in config.toml
#   - Gemini CLI, OpenCode: embedded in settings JSON under mcpServers/mcp key
#   - Cline: JSON in VS Code extension dir (not auto-managed)
#   - Aider: no MCP support
#
# Usage:
#   formatMcpJson servers   => JSON string for Claude/Cursor/Windsurf/Pi
#   formatMcpToml pkgs servers => store path to TOML file (Codex)
#   formatMcpAttrs servers  => attrset for embedding in parent JSON (Gemini/OpenCode)
{ lib }:
{
  # Format MCP servers as a JSON string with { mcpServers: { ... } } wrapper.
  # Used by: Claude Code (.mcp.json), Cursor (.cursor/mcp.json),
  #          Windsurf (~/.codeium/windsurf/mcp_config.json), Pi (.pi/mcp.json)
  formatMcpJson =
    servers:
    builtins.toJSON {
      mcpServers = lib.mapAttrs (
        _: srv:
        {
          inherit (srv) command;
        }
        // lib.optionalAttrs (srv.args != [ ]) { inherit (srv) args; }
        // lib.optionalAttrs (srv.env != { }) { inherit (srv) env; }
        // lib.optionalAttrs (srv.type != "stdio") { inherit (srv) type; }
        // lib.optionalAttrs (srv.url != null) { inherit (srv) url; }
      ) servers;
    };

  # Format MCP servers as a TOML config file via JSON -> remarshal conversion.
  # Returns a store derivation (path), not a string.
  # Used by: Codex CLI (config.toml)
  formatMcpToml =
    pkgs: servers:
    let
      jsonContent = builtins.toJSON {
        mcp_servers = lib.mapAttrs (
          _: srv:
          {
            inherit (srv) command;
          }
          // lib.optionalAttrs (srv.args != [ ]) { inherit (srv) args; }
          // lib.optionalAttrs (srv.env != { }) { inherit (srv) env; }
        ) servers;
      };
      jsonFile = pkgs.writeText "codex-mcp.json" jsonContent;
    in
    pkgs.runCommand "codex-mcp.toml" { nativeBuildInputs = [ pkgs.remarshal ]; } ''
      remarshal -if json -of toml < ${jsonFile} > $out
    '';

  # Format MCP servers as a plain attrset for embedding in a parent JSON config.
  # The caller merges this into the tool's settings.json before serializing.
  # Used by: Gemini CLI (settings.json mcpServers key),
  #          OpenCode (opencode.json mcp key)
  formatMcpAttrs =
    servers:
    lib.mapAttrs (
      _: srv:
      {
        inherit (srv) command;
      }
      // lib.optionalAttrs (srv.args != [ ]) { inherit (srv) args; }
      // lib.optionalAttrs (srv.env != { }) { inherit (srv) env; }
      // lib.optionalAttrs (srv.url != null) { inherit (srv) url; }
    ) servers;
}
