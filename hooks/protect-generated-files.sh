#!/usr/bin/env bash
# PreToolUse hook: block edits to generated/lock files

set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Normalize to relative path for matching
rel_path="${file_path#"${CLAUDE_PROJECT_DIR}"/}"

case "$rel_path" in
  settings.json)
    # shellcheck disable=SC2016
    printf 'Blocked: settings.json is generated from settings.nix. Edit settings.nix and run `just generate-settings`.\n' >&2
    exit 2
    ;;
  */.claude-plugin/plugin.json | */plugin.json)
    # shellcheck disable=SC2016
    printf 'Blocked: plugin.json is generated from plugin.nix. Edit plugin.nix and run `just generate-manifests`.\n' >&2
    exit 2
    ;;
  */.mcp.json)
    # shellcheck disable=SC2016
    printf 'Blocked: .mcp.json is generated from plugin.nix. Edit plugin.nix and run `just generate-manifests`.\n' >&2
    exit 2
    ;;
  */.lsp.json)
    # shellcheck disable=SC2016
    printf 'Blocked: .lsp.json is generated from plugin.nix. Edit plugin.nix and run `just generate-manifests`.\n' >&2
    exit 2
    ;;
  flake.lock)
    # shellcheck disable=SC2016
    printf 'Blocked: flake.lock is managed by Nix. Run `nix flake update` or `just update`.\n' >&2
    exit 2
    ;;
  result | result/*)
    printf 'Blocked: result/ is a Nix build output symlink, not editable source.\n' >&2
    exit 2
    ;;
esac
