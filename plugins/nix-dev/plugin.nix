{ pkgs }:
{
  name = "nix-dev";
  version = "0.1.0";
  description = "Nix development intelligence: Nix language, NixOS modules, flakes, devenv, nixpkgs, home-manager, plus nil LSP and mcp-nixos integration";
  author.name = "Markus Jylhänkangas";

  packages = [ pkgs.nil ];

  mcpServers = {
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

  lspServers = {
    nix = {
      command = "nil";
      args = [ ];
      extensionToLanguage = {
        ".nix" = "nix";
      };
    };
  };
}
