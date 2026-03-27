{ pkgs, lib, config, ... }:

{
  # Playwright browsers from nix
  env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  packages = [
    pkgs.git
    pkgs.gh
    pkgs.playwright-driver
  ];

  # Bun runtime + auto-install deps on shell entry
  languages.javascript.bun.enable = true;
  languages.javascript.bun.install.enable = true;

  # Claude Code with devenv MCP server
  claude.code = {
    enable = true;
    mcpServers = {
      devenv = {
        type = "stdio";
        command = "devenv";
        args = [ "mcp" ];
        env = {
          DEVENV_ROOT = config.devenv.root;
        };
      };
    };
  };

  enterShell = ''
    echo "gstack dev shell ready — bun $(bun --version), playwright ${pkgs.playwright-driver.version}"
  '';

  enterTest = ''
    echo "Running tests"
    bun --version
    git --version
    bun test
  '';
}
