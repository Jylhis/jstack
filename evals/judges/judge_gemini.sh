#!/usr/bin/env bash
# Google Gemini judge wrapper for promptfoo's g-eval `provider:` override.
# Default judge for cross-vendor evaluation when SUT is Claude/Codex/Pi.

# shellcheck source=evals/providers/lib.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../providers/lib.sh"

emit_family_if_requested google "${1:-}"

require_cmd jq gemini

PROMPT="${1:?prompt required as argv[1]}"
WORKDIR="${2:-$(mktemp -d -t judge-gemini-XXXXXX)}"
mkdir -p "$WORKDIR"

CLI_VERSION="$(gemini --version 2>/dev/null | head -n1 || echo unknown)"
START="$(millis_now)"

TRACE="$WORKDIR/judge-trace.json"
(
  cd "$WORKDIR"
  gemini -p "$PROMPT" --output-format stream-json \
    > "$TRACE" 2>"$WORKDIR/stderr.log"
) || {
  status=$?
  cat "$WORKDIR/stderr.log" >&2
  exit "$status"
}

ELAPSED=$(( $(millis_now) - START ))

TEXT="$(jq -r 'select(.type == "response") | .response // empty' "$TRACE" 2>/dev/null | tail -n1)"
if [[ -z "$TEXT" ]]; then
  TEXT="$(jq -r 'select(.type == "text") | .text // empty' "$TRACE" 2>/dev/null | paste -sd '' -)"
fi

printf '%s' "$TEXT"

emit_trace 'null' "$ELAPSED" google gemini "$CLI_VERSION" judge
