#!/usr/bin/env bash
# Shared helpers for claude-stack hooks. Source, do not execute.

# Read hook input once.
HOOK_INPUT="$(cat)"

# Guards that must hold even when broken export FAIL_CLOSED=1 before sourcing this file.
# Checked here, not in json_get: json_get runs in $(...), where exit only ends the subshell.
if [[ "${FAIL_CLOSED:-0}" == "1" ]] && ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  echo "BLOCKED by claude-stack: neither jq nor python3 found, so this guard cannot check the command. Install jq." >&2
  exit 2
fi

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

# ask <message> — let the user decide in the permission prompt instead of a hard deny.
# For actions that are fine in some contexts (destructive SQL on a local DB).
ask() {
  local msg="claude-stack: $1"
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg r "$msg" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'
  else
    python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":sys.argv[1]}}))' "$msg"
  fi
  exit 0
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
