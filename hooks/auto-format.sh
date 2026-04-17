#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Edit or Write using treefmt

set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
  exit 0
fi

if ! command -v treefmt &>/dev/null; then
  exit 0
fi

treefmt "$file_path" 2>/dev/null || true
