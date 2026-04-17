# Consolidated MCP server, LSP server, and runtime package registry.
#
# Canonical source for all binary tooling that jstack ships.
# Consumers:
#   - runtime/default.nix            → packages (buildEnv)
#   - scripts/install.bash           → mcpServers, lspServers (generates .mcp.json / .lsp.json)
#   - Justfile generate-servers      → same
#   - modules/mcp.nix, modules/lsp.nix → default server sets for v2 module
{ pkgs }:
{
  # ── MCP servers ──────────────────────────────────────────────────────
  mcpServers = {
    # gopls ships a built-in MCP server since v0.20.
    gopls = {
      type = "stdio";
      command = "gopls";
      args = [ "mcp" ];
    };

    # gradle-mcp (rnett) via JBang. First run downloads into JBang cache.
    gradle = {
      type = "stdio";
      command = "jbang";
      args = [
        "run"
        "gradle-mcp@rnett"
      ];
    };

    # NixOS option and package lookups.
    mcp-nixos = {
      type = "stdio";
      command = "nix";
      args = [
        "run"
        "github:utensils/mcp-nixos"
        "--"
      ];
    };
  };

  # ── LSP servers ──────────────────────────────────────────────────────
  lspServers = {
    go = {
      command = "gopls";
      args = [ "serve" ];
      extensionToLanguage = {
        ".go" = "go";
      };
    };

    java = {
      command = "jdtls";
      args = [ ];
      extensionToLanguage = {
        ".java" = "java";
      };
    };

    kotlin = {
      command = "kotlin-language-server";
      args = [ ];
      extensionToLanguage = {
        ".kt" = "kotlin";
        ".kts" = "kotlin";
      };
    };

    nix = {
      command = "nil";
      args = [ ];
      extensionToLanguage = {
        ".nix" = "nix";
      };
    };

    python = {
      command = "pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };

    rust = {
      command = "rust-analyzer";
      args = [ ];
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };

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

  # ── Runtime packages ─────────────────────────────────────────────────
  # All binaries that jstack-runtime puts on PATH.
  packages = with pkgs; [
    gopls
    jdt-language-server
    kotlin-language-server
    jbang
    nil
    pyright
    ruff
    uv
    typescript-language-server
  ];
}
