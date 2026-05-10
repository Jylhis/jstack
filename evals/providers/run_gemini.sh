#!/usr/bin/env bash
# Google Gemini CLI provider for promptfoo's `exec:` lane.

# shellcheck source=evals/providers/lib.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib.sh"

emit_family_if_requested google "${1:-}"

require_cmd jq python3 gemini

PROMPT="${1:?prompt required as argv[1]}"
# argv[2+] is reserved for promptfoo's options JSON; ignore it.
WORKDIR="${EVAL_WORKDIR:-$(mktemp -d -t eval-gemini-XXXXXX)}"
mkdir -p "$WORKDIR"

CLI_VERSION="$(gemini --version 2>/dev/null | head -n1 || echo unknown)"
MODEL_SNAPSHOT="${EVAL_GEMINI_MODEL:-default}"

START="$(millis_now)"

TRACE_FILE="$WORKDIR/gemini-trace.json"
(
  cd "$WORKDIR"
  gemini -p "$PROMPT" --output-format stream-json \
    > "$TRACE_FILE" 2>"$WORKDIR/gemini-stderr.log"
) || {
  status=$?
  cat "$WORKDIR/gemini-stderr.log" >&2
  exit "$status"
}

ELAPSED=$(( $(millis_now) - START ))

# Gemini's stream-json output is NDJSON; the final assistant text is
# the concatenation of `text` events, with a non-stream-final
# `response` event as the canonical fallback.
TEXT="$(jq -r '
  select(.type == "response") | .response // empty
' "$TRACE_FILE" 2>/dev/null | tail -n1)"

if [[ -z "$TEXT" ]]; then
  TEXT="$(jq -r '
    select(.type == "text") | .text // empty
  ' "$TRACE_FILE" 2>/dev/null | paste -sd '' -)"
fi

# `activate_skill` is Gemini's explicit skill-load tool; its
# `args.skill` carries the activated skill name. Some Gemini versions
# expose this via `stats.tools.byName.activate_skill`; we look for both.
TRIGGERED_RAW="$(jq -r '
  select(.type == "tool_use" and .name == "activate_skill")
  | (.input.skill // .args.skill // empty)
' "$TRACE_FILE" 2>/dev/null | head -n1)"

if [[ -z "$TRIGGERED_RAW" ]]; then
  TRIGGERED_RAW="$(jq -r '
    select(.stats != null) | .stats.tools.byName.activate_skill.lastSkill // empty
  ' "$TRACE_FILE" 2>/dev/null | head -n1)"
fi

if [[ -n "$TRIGGERED_RAW" ]]; then
  TRIGGERED_JSON="$(jq -nc --arg s "$TRIGGERED_RAW" '$s')"
else
  TRIGGERED_JSON='null'
fi

printf '%s' "$TEXT"

emit_trace "$TRIGGERED_JSON" "$ELAPSED" google gemini "$CLI_VERSION" "$MODEL_SNAPSHOT"
