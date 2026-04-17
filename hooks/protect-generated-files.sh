#!/usr/bin/env bash
# PreToolUse hook: block edits to generated/lock files
# shellcheck disable=SC2016

set -euo pipefail

command -v jq &>/dev/null || exit 0

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Normalize to relative path for matching
rel_path="${file_path#"${CLAUDE_PROJECT_DIR}"/}"

case "$rel_path" in
  settings.json)
    printf 'Blocked: settings.json is generated from settings.nix. Edit settings.nix and run `just generate-settings`.\n' >&2
    exit 2
    ;;
  .mcp.json | .lsp.json)
    printf 'Blocked: %s is generated from lib/servers.nix. Edit lib/servers.nix and run `just generate-servers`.\n' "$(basename "$rel_path")" >&2
    exit 2
    ;;
  flake.lock)
    printf 'Blocked: flake.lock is managed by Nix. Run `nix flake update` or `just update`.\n' >&2
    exit 2
    ;;
  result | result/*)
    printf 'Blocked: result/ is a Nix build output symlink, not editable source.\n' >&2
    exit 2
    ;;
esac
