#!/usr/bin/env bash
# gate-scan: list diff hunks where a quality gate may have been weakened.
# Adapted from gstack's Gate Integrity catalog (RH-* ids). It inventories and tags;
# it never judges. Each hit is a lead that a human or reviewer must read.
#
# Usage: gate-scan.sh [base-ref]     default: working tree + index vs HEAD
# Output: one line per hit "RH-<id>  <path>:<line>  <added|removed>  <snippet>",
#         then "GATE-SCAN: <n> hit(s)" or "GATE-SCAN: none". Exit 0 unless git fails.
set -uo pipefail

base="${1:-HEAD}"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "GATE-SCAN: not a git repository" >&2; exit 1; }

diff_out="$(git diff --no-color --unified=0 "$base" -- . 2>/dev/null)" || { echo "GATE-SCAN: git diff $base failed" >&2; exit 1; }
# Untracked files count as fully added.
while IFS= read -r f; do
  [[ -f "$f" ]] || continue
  diff_out+=$'\n'"$(git diff --no-color --unified=0 --no-index /dev/null "$f" 2>/dev/null)"
done < <(git ls-files --others --exclude-standard)

changed_files="$(printf '%s\n' "$diff_out" | sed -n 's|^+++ b/||p' | sort -u)"

printf '%s\n' "$diff_out" | awk -v changed="$changed_files" '
function is_test(p) {
  return p ~ /(\.test|\.spec)\.(ts|tsx|js|jsx|mts|cts)$/ || p ~ /_test\.go$/ || p ~ /(^|\/)(tests?|__tests__|e2e|testdata|fixtures)\// || p ~ /\.snap$/
}
function is_snapshot(p) { return p ~ /(__snapshots__\/|\.snap$|\.golden$|(^|\/)testdata\/)/ }
function is_gate_cfg(p) {
  return is_test(p) || p ~ /(^|\/)\.github\/workflows\// || p ~ /(vitest|vite|jest|playwright)\.config\./ || p ~ /(^|\/)(biome\.jsonc?|tsconfig[^\/]*\.json|\.golangci\.ya?ml|clippy\.toml|Cargo\.toml|package\.json)$/
}
function hit(id, sign, text,   s) {
  s = text; gsub(/^[ \t]+/, "", s); if (length(s) > 110) s = substr(s, 1, 107) "..."
  printf "%-7s %s:%d  %s  %s\n", id, file, (sign == "+" ? nline : oline), (sign == "+" ? "added" : "removed"), s
  n++
}
BEGIN { split(changed, cf, "\n"); for (i in cf) changedset[cf[i]] = 1; n = 0 }
/^diff --git / { file = ""; next }
/^--- / { oldfile = substr($0, 5); sub(/^a\//, "", oldfile); next }
/^\+\+\+ / {
  file = substr($0, 5); sub(/^b\//, "", file)
  if (file == "/dev/null") file = oldfile
  if (is_snapshot(file)) {
    owner = file; sub(/__snapshots__\//, "", owner); sub(/\.snap$/, "", owner)
    if (!(owner in changedset)) { nline = 1; hit("RH-3?", "+", "snapshot/golden changed without its owning test in the diff") }
  }
  next
}
/^@@ / {
  match($0, /-[0-9]+/); oline = substr($0, RSTART + 1, RLENGTH - 1) + 0
  match($0, /\+[0-9]+/); nline = substr($0, RSTART + 1, RLENGTH - 1) + 0
  next
}
/^[+-]/ {
  sign = substr($0, 1, 1); line = substr($0, 2); t = is_test(file)
  if (sign == "+") {
    if (t && line ~ /(\.(skip|only|todo)\(|(^|[^A-Za-z])x(it|describe|test)\(|t\.Skip(Now|f)?\(|#\[ignore\]|@pytest\.mark\.skip)/) hit("RH-1", sign, line)
    if (!t && line ~ /(todo!\(|unimplemented!\(|panic\("(not implemented|TODO|todo)|[Nn]ot implemented["'\''`])/) hit("RH-4", sign, line)
    if (!t && line ~ /(NODE_ENV[ \t]*[!=]==?[ \t]*["'\'']test|process\.env\.(CI|VITEST|JEST_WORKER_ID)|import\.meta\.env\.(MODE|VITEST)|testing\.Testing\(\)|os\.Getenv\("CI"\)|cfg!\(test\))/) hit("RH-12", sign, line)
    if (line ~ /(@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|biome-ignore|#\[allow\(|\/\/[ \t]*nolint|#[ \t]*type:[ \t]*ignore|#[ \t]*noqa)/) hit("RH-13", sign, line)
    if (line ~ /(--no-verify|continue-on-error:[ \t]*true|allow_failure:[ \t]*true|\[skip ci\]|\[ci skip\])/) hit("RH-14", sign, line)
    if (!t && line ~ /(catch[ \t]*(\([^)]*\))?[ \t]*\{[ \t]*\}|\.catch\([ \t]*\(\)[ \t]*=>[ \t]*(\{[ \t]*\}|undefined|null)[ \t]*\)|^[ \t]*_[ \t]*=[ \t]*err[ \t]*$)/) hit("RH-16", sign, line)
    if (is_gate_cfg(file) && line ~ /([Tt]imeout|[Rr]etr(y|ies)|[Tt]hreshold|[Cc]overage|[Tt]olerance|[Ee]psilon|toBeGreaterThan|toBeGreaterThanOrEqual|toBeLessThan|toBeCloseTo|testTimeout|hookTimeout)/ && line ~ /[0-9]/) hit("RH-15?", sign, line)
  } else {
    if (t && line ~ /(^[ \t]*(it|test|describe)(\.each\([^)]*\))?\(|^[ \t]*func Test[A-Z_]|#\[(tokio::)?test\]|^[ \t]*def test_)/) hit("RH-1", sign, line)
    if (t && line ~ /(expect\(|assert|require\.|t\.(Error|Fatal)|assert_eq!|assert!\()/) hit("RH-1?", sign, line)
    if (file ~ /(^|\/)docs\/specs\/.*\/spec\.md$/ && line ~ /AC[0-9]+/) hit("RH-10", sign, line)
  }
  if (sign == "+") nline++; else oline++
}
END {
  if (n == 0) print "GATE-SCAN: none"; else printf "GATE-SCAN: %d hit(s). Read each: does it silence the failure the gate exists for, or is it justified in this diff?\n", n
}'
