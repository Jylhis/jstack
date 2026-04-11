{ pkgs }:
{
  name = "rust-dev";
  version = "1.0.0";
  description = "Rust development intelligence: 29 skills covering ownership, lifetimes, error handling, concurrency, domain patterns, and LSP tooling plus rust-analyzer integration";
  author.name = "Markus Jylhänkangas";

  packages = [ ];

  lspServers = {
    rust = {
      command = "rust-analyzer";
      args = [ ];
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
  };

  # mcpServers intentionally omitted.
  # rust-mcp-server (Vaiz) and cargo-mcp (jbr) ship via `cargo install`, and
  # crates-mcp / rust-analyzer-mcp are not in nixpkgs either. The jstack rule
  # requires tools on PATH via devenv — no cargo-install bootstrap. Revisit
  # once any rust cargo/crates MCP server lands in nixpkgs or ships a Nix flake.
}
