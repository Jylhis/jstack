# MCP module — declares shared mcpServers options.
#
# MCP servers are configured once and deployed to each enabled tool
# in the tool's specific format (JSON, TOML, embedded).
# Tool modules read cfg.mcpServers and format them via lib/mcp-format.nix.
{
  lib,
  ...
}:
{
  options.programs.jstack.mcpServers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          command = lib.mkOption {
            type = lib.types.str;
            description = "Command to start the MCP server.";
          };

          args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Arguments passed to the MCP server command.";
          };

          env = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Environment variables for the MCP server.";
          };

          type = lib.mkOption {
            type = lib.types.enum [
              "stdio"
              "sse"
              "http"
            ];
            default = "stdio";
            description = "Transport type for the MCP server.";
          };

          url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "URL for sse/http transports.";
          };
        };
      }
    );
    default = { };
    description = ''
      MCP servers shared across all enabled tools.
      Each tool module formats these into its specific config format.
    '';
    example = {
      github = {
        command = "github-mcp-server";
        args = [ "--stdio" ];
        env.GITHUB_TOKEN = "\${GITHUB_TOKEN}";
      };
    };
  };
}
