# LSP module — declares shared lspServers options.
#
# LSP servers are configured once and deployed to tools that support them.
{ lib, ... }:
{
  options.programs.jstack.lspServers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          command = lib.mkOption {
            type = lib.types.str;
            description = "Command to start the LSP server.";
          };

          args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Arguments passed to the LSP server command.";
          };

          extensionToLanguage = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Map of file extensions to language identifiers.";
            example = {
              ".ts" = "typescript";
              ".tsx" = "typescriptreact";
            };
          };
        };
      }
    );
    default = { };
    description = "LSP servers shared across all enabled tools that support LSP.";
  };
}
