#!/usr/bin/env bash
# PreToolUse(Edit/Write): during the TDD GREEN phase test files are frozen.
# Phase lives in <project>/.claude/tdd-phase, written by the tdd skill.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

root="$(project_dir)"
phase_file="$root/.claude/tdd-phase"
[[ -f "$phase_file" ]] || exit 0
phase="$(tr -d '[:space:]' <"$phase_file")"
[[ "$phase" == "green" ]] || exit 0

path="$(json_get .tool_input.file_path)"
[[ -z "$path" ]] && path="$(json_get .tool_input.notebook_path)"
[[ -z "$path" ]] && exit 0

case "$path" in
  *.test.ts|*.test.tsx|*.test.js|*.test.jsx|*.test.mts|*.spec.ts|*.spec.tsx|*.spec.js|*.spec.jsx|*.spec.mts|\
  *_test.go|*/__tests__/*|*/tests/*|*/test/*|*/e2e/*|*.snap|*/__snapshots__/*|*/testdata/*|*/fixtures/*)
    block "TDD GREEN phase: test files are frozen ($(basename "$path")). Make the production code pass the test. If the test is wrong, stop and explain it to the user."
    ;;
esac
exit 0
