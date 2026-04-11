{ pkgs }:
{
  name = "typescript-dev";
  version = "0.1.0";
  description = "TypeScript / JavaScript development intelligence: TS 5.9+ on Node 22 LTS, pnpm, vitest, ESLint 9 flat config, Prettier, plus typescript-language-server LSP";
  author.name = "Markus Jylhänkangas";

  packages = [
    pkgs.typescript-language-server
  ];

  lspServers = {
    typescript = {
      command = "typescript-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
        ".mjs" = "javascript";
        ".cjs" = "javascript";
      };
    };
  };

  # mcpServers intentionally omitted from v0.1.
  # The ESLint MCP (@eslint/mcp) is published on npm and would require an
  # npx bootstrap, which is disallowed in jstack (tools must be on PATH via
  # devenv). Revisit once @eslint/mcp lands in nixpkgs or we add a node2nix
  # derivation for it. Context7 is language-agnostic and belongs at the
  # runtime level, not per-plugin.
}
