{ pkgs }:
{
  name = "golang-dev";
  description = "Go development intelligence: 36 skills covering idioms, patterns, testing, performance, security, and modern syntax plus gopls LSP";
  author.name = "Markus Jylhänkangas";

  packages = [ ];

  lspServers = {
    go = {
      command = "gopls";
      args = [ "serve" ];
      extensionToLanguage = {
        ".go" = "go";
      };
    };
  };
}
