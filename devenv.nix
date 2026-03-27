{
  pkgs,
  lib,
  config,
  ...
}:

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
  languages = {
    javascript = {
      enable = true;
      package = pkgs.nodejs;
      bun = {
        enable = true;
        install.enable = true;
      };
    };
    nix = {
      enable = true;
      lsp.enable = true;
    };
  };

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
      actionlint.enable = true;
    };
  };

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

  # dev-teardown: remove dev skill symlinks, restore global jstack install
  scripts.dev-teardown = {
    description = "Remove dev skill symlinks and restore global jstack install";
    exec = ''
      _REPO_ROOT="$(git rev-parse --show-toplevel)"
      _removed=()

      # Clean up .claude/skills/
      _CLAUDE_SKILLS="$_REPO_ROOT/.claude/skills"
      if [ -d "$_CLAUDE_SKILLS" ]; then
        for link in "$_CLAUDE_SKILLS"/*/; do
          name="$(basename "$link")"
          [ "$name" = "jstack" ] && continue
          if [ -L "''${link%/}" ]; then
            rm "''${link%/}"
            _removed+=("claude/$name")
          fi
        done
        if [ -L "$_CLAUDE_SKILLS/jstack" ]; then
          rm "$_CLAUDE_SKILLS/jstack"
          _removed+=("claude/jstack")
        fi
        rmdir "$_CLAUDE_SKILLS" 2>/dev/null || true
        rmdir "$_REPO_ROOT/.claude" 2>/dev/null || true
      fi

      # Clean up .agents/skills/
      _AGENTS_SKILLS="$_REPO_ROOT/.agents/skills"
      if [ -d "$_AGENTS_SKILLS" ]; then
        for link in "$_AGENTS_SKILLS"/*/; do
          name="$(basename "$link")"
          [ "$name" = "jstack" ] && continue
          if [ -L "''${link%/}" ]; then
            rm "''${link%/}"
            _removed+=("agents/$name")
          fi
        done
        if [ -L "$_AGENTS_SKILLS/jstack" ]; then
          rm "$_AGENTS_SKILLS/jstack"
          _removed+=("agents/jstack")
        fi
        rmdir "$_AGENTS_SKILLS" 2>/dev/null || true
        rmdir "$_REPO_ROOT/.agents" 2>/dev/null || true
      fi

      if [ ''${#_removed[@]} -gt 0 ]; then
        echo "Removed: ''${_removed[*]}"
      else
        echo "No symlinks found."
      fi
      echo "Dev mode deactivated. Global jstack (~/.claude/skills/jstack) is now active."
    '';
  };

  enterShell = ''
    _REPO_ROOT="$(pwd)"

    # 1. Copy .env from main worktree if this is a worktree and .env is missing
    if [ ! -f "$_REPO_ROOT/.env" ]; then
      _MAIN_WORKTREE="$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')"
      if [ -n "$_MAIN_WORKTREE" ] && [ "$_MAIN_WORKTREE" != "$_REPO_ROOT" ] && [ -f "$_MAIN_WORKTREE/.env" ]; then
        cp "$_MAIN_WORKTREE/.env" "$_REPO_ROOT/.env"
        echo "Copied .env from main worktree ($_MAIN_WORKTREE)"
      fi
    fi

    # 3-5. Create skill symlinks (idempotent — skip if jstack symlink already correct)
    _JSTACK_LINK="$_REPO_ROOT/.claude/skills/jstack"
    _AGENTS_LINK="$_REPO_ROOT/.agents/skills/jstack"
    _NEEDS_SETUP=0

    if [ -L "$_JSTACK_LINK" ] && [ "$(readlink "$_JSTACK_LINK")" = "$_REPO_ROOT" ]; then
      : # symlink exists and points to the right place
    else
      mkdir -p "$_REPO_ROOT/.claude/skills"
      if [ -d "$_JSTACK_LINK" ] && [ ! -L "$_JSTACK_LINK" ]; then
        echo "Warning: .claude/skills/jstack is a real directory, not a symlink." >&2
        echo "Remove it manually if you want to use dev mode." >&2
      else
        [ -L "$_JSTACK_LINK" ] && rm "$_JSTACK_LINK"
        ln -s "$_REPO_ROOT" "$_JSTACK_LINK"
        _NEEDS_SETUP=1
      fi
    fi

    mkdir -p "$_REPO_ROOT/.agents/skills"
    if [ -L "$_AGENTS_LINK" ] && [ "$(readlink "$_AGENTS_LINK")" = "$_REPO_ROOT" ]; then
      : # already correct
    elif [ -d "$_AGENTS_LINK" ] && [ ! -L "$_AGENTS_LINK" ]; then
      echo "Warning: .agents/skills/jstack is a real directory, skipping." >&2
    else
      [ -L "$_AGENTS_LINK" ] && rm "$_AGENTS_LINK"
      ln -s "$_REPO_ROOT" "$_AGENTS_LINK"
    fi

    # 6. Run setup through the symlink (only if symlinks were just created or per-skill symlinks missing)
    if [ "$_NEEDS_SETUP" -eq 1 ] || [ ! -L "$_REPO_ROOT/.claude/skills/review" ]; then
      "$_JSTACK_LINK/setup"
    fi

    echo "jstack dev shell ready — bun $(bun --version), playwright ${pkgs.playwright-driver.version}"
  '';

  enterTest = ''
    echo "Running tests"
    bun --version
    git --version
    bun test
  '';
}
