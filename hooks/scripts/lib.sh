#!/usr/bin/env bash
# Shared helpers for claude-stack hooks. Source, do not execute.

# Read hook input once.
HOOK_INPUT="$(cat)"

# json_get <jq-path>  — prints the value or empty string.
json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | python3 -c '
import json, sys
path = sys.argv[1].lstrip(".").split(".")
try:
    v = json.load(sys.stdin)
    for k in path:
        v = v.get(k) if isinstance(v, dict) else None
    print("" if v is None else v, end="")
except Exception:
    pass' "$1"
  else
    echo "claude-stack: neither jq nor python3 found; guard skipped" >&2
    exit 0
  fi
}

# block <message> — deny the tool call and tell Claude why.
block() {
  echo "BLOCKED by claude-stack: $1" >&2
  exit 2
}

project_dir() {
  printf '%s' "${CLAUDE_PROJECT_DIR:-$(json_get .cwd)}"
}

# tdd_phase <root> — current TDD phase word, or empty. Written by scripts/tdd-phase.sh into
# .claude-stack/tdd-phase ("<phase> <task-id>"); .claude/tdd-phase is read as a legacy fallback.
tdd_phase() {
  local f
  for f in "$1/.claude-stack/tdd-phase" "$1/.claude/tdd-phase"; do
    [[ -f "$f" ]] && { awk 'NR==1{print $1}' "$f"; return 0; }
  done
  return 0
}
