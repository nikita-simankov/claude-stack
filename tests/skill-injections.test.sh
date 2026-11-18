#!/usr/bin/env bash
# Every !`cmd` injection in a SKILL.md must exit 0: a non-zero exit makes Claude Code abort
# loading the whole skill. Runs each command in an empty dir and in a git repo with a feature branch.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/empty" "$T/repo"
( cd "$T/repo" && git init -q && git config user.email t@t && git config user.name t && echo a > a && git add a && git commit -qm a && git branch -M main && git checkout -qb feat && echo b > b && git add b && git commit -qm b ) >/dev/null
pass=0; failed=0
while IFS=$'\t' read -r file cmd; do
  for dir in "$T/empty" "$T/repo"; do
    if (cd "$dir" && CLAUDE_PLUGIN_ROOT="$ROOT" bash -c "$cmd") >/dev/null 2>&1; then pass=$((pass + 1))
    else failed=$((failed + 1)); printf '  FAIL  %s (in %s): %s\n' "$file" "$(basename "$dir")" "$cmd"; fi
  done
done < <(python3 - "$ROOT" <<'PY'
import re, sys, pathlib
for p in sorted(pathlib.Path(sys.argv[1], "skills").glob("*/SKILL.md")):
    for m in re.finditer(r'(?:^|\s)!`([^`]+)`', p.read_text()):
        print(f"{p.parent.name}\t{m.group(1)}")
PY
)
printf '  skill injections: %d passed, %d failed\n' "$pass" "$failed"
((failed == 0))
