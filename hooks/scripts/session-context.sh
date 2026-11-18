#!/usr/bin/env bash
# SessionStart: inject a compact snapshot of where work stands. Stdout goes into context.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

root="$(project_dir)"
[[ -d "$root" ]] || exit 0
cd "$root" || exit 0

out=""
add() { out+="$1"$'\n'; }

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  add "## claude-stack session context"
  add "Branch: $(git branch --show-current 2>/dev/null || echo detached)"
  changes="$(git status --short 2>/dev/null | head -20)"
  if [[ -n "$changes" ]]; then
    add "Uncommitted changes (first 20):"
    add '```'
    add "$changes"
    add '```'
  fi
fi

phase="$(tdd_phase "$root")"
[[ -n "$phase" ]] && add "TDD phase in progress: $phase (scripts/tdd-phase.sh show; clear it if the cycle was abandoned)"

shopt -s nullglob
for f in docs/specs/*/tasks.md; do
  open="$(grep -Ec '^\s*- \[( |~)\]' "$f" || true)"
  [[ "$open" -gt 0 ]] || continue
  current="$(grep -Em1 '^\s*- \[~\]' "$f" || grep -Em1 '^\s*- \[ \]' "$f")"
  add "Active spec: $f — $open open task(s). Current: ${current#"${current%%[![:space:]]*}"}"
done

if [[ -f HANDOFF.md ]]; then
  add ""
  add "HANDOFF.md from the previous session (read before doing anything else):"
  add "$(head -80 HANDOFF.md)"
fi

[[ -n "$out" ]] && printf '%s' "$out"
exit 0
