{ pkgs }:
{
  name = "python-dev";
  version = "0.1.0";
  description = "Python development intelligence: Python 3.12+, uv, ruff, pytest, pyright, FastAPI, Pydantic v2, plus pyright LSP";
  author.name = "Markus Jylhänkangas";

  packages = [
    pkgs.pyright
    pkgs.ruff
    pkgs.uv
  ];

  lspServers = {
    python = {
      command = "pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
  };

  # mcpServers intentionally omitted from v0.1.
  # ruff-mcp-server (drewsonne) is a uv-installable package; bootstrapping
  # via `uvx` is the npx-equivalent and conflicts with the jstack rule that
  # tools live on PATH via devenv. Revisit once we have a Nix derivation,
  # a flake, or a direct nixpkgs package for ruff-mcp-server.
}
