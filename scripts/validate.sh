#!/usr/bin/env bash
# Validate the stack: manifests, frontmatter, JSON, shell scripts, hook behaviour.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
ok()  { printf '  ok    %s\n' "$*"; }
bad() { printf '  FAIL  %s\n' "$*"; fail=1; }

fm() { # fm <file> <key> — read a top-level frontmatter value
  awk -v k="$2" 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1 && index($0, k": ")==1{sub(k": ",""); print; exit}' "$1"
}

echo "JSON"
while IFS= read -r f; do
  jq empty "$f" 2>/dev/null && ok "$f" || bad "$f is not valid JSON"
done < <(find . -name '*.json' -not -path './.git/*' -not -path '*/node_modules/*')

echo "Skills"
for d in skills/*/; do
  n="$(basename "$d")"; f="$d/SKILL.md"
  [[ -f "$f" ]] || { bad "$n: missing SKILL.md"; continue; }
  [[ "$(fm "$f" name)" == "$n" ]] || bad "$n: frontmatter name != directory"
  [[ -n "$(fm "$f" description)" ]] || bad "$n: missing description"
  lines=$(wc -l <"$f"); ((lines <= 200)) || bad "$n: SKILL.md is $lines lines (>200), move detail to references/"
  ok "$n"
done

echo "Agents"
for f in agents/*.md; do
  n="$(basename "$f" .md)"
  [[ "$(fm "$f" name)" == "$n" ]] || bad "$n: frontmatter name != filename"
  [[ -n "$(fm "$f" description)" ]] || bad "$n: missing description"
  [[ -n "$(fm "$f" tools)" ]] || bad "$n: no tools list (least privilege is required)"
  ok "$n"
done

echo "Shell"
for f in hooks/scripts/*.sh scripts/*.sh tests/*.sh; do
  bash -n "$f" || { bad "$f: syntax"; continue; }
  if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -x -S warning "$f" >/dev/null || { bad "$f: shellcheck"; shellcheck -x -S warning "$f" | head -20; continue; }
  fi
  ok "$f"
done
command -v shellcheck >/dev/null 2>&1 || echo "  (shellcheck not installed — skipped lint)"

echo "Hook and script tests"
bash tests/hooks.test.sh || fail=1
bash tests/gate-scan.test.sh || fail=1
bash tests/skill-injections.test.sh || fail=1

echo "Plugin manifest"
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . >/dev/null 2>&1 && ok "claude plugin validate" || { bad "claude plugin validate"; claude plugin validate . | tail -20; }
else
  echo "  (claude CLI not installed — skipped)"
fi

((fail)) && { echo "VALIDATION FAILED"; exit 1; }
echo "All checks passed."
