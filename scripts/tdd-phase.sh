#!/usr/bin/env bash
# tdd-phase: set or show the TDD phase that arms the guard-tests hook.
#   tdd-phase.sh red|green|refactor [task-id]   write the phase
#   tdd-phase.sh clear                          remove it (cycle closed or abandoned)
#   tdd-phase.sh show                           print "<phase> <task-id>" or "none"
# State lives in <project>/.claude-stack/tdd-phase. The directory ignores itself in git,
# and unlike .claude/ it is writable without a permission prompt.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
dir="$root/.claude-stack"
file="$dir/tdd-phase"
legacy="$root/.claude/tdd-phase"

case "${1:-show}" in
  red|green|refactor)
    mkdir -p "$dir"
    [[ -f "$dir/.gitignore" ]] || printf '*\n' >"$dir/.gitignore"
    printf '%s %s\n' "$1" "${2:--}" >"$file"
    echo "tdd-phase: $1 ${2:--} ($file)"
    ;;
  clear)
    rm -f "$file"
    [[ -w "$legacy" ]] && rm -f "$legacy" 2>/dev/null || true
    echo "tdd-phase: cleared"
    ;;
  show)
    if [[ -f "$file" ]]; then cat "$file"
    elif [[ -f "$legacy" ]]; then printf '%s - (legacy .claude/tdd-phase)\n' "$(tr -d '[:space:]' <"$legacy")"
    else echo none; fi
    ;;
  *) echo "usage: tdd-phase.sh red|green|refactor [task-id] | clear | show" >&2; exit 2 ;;
esac
