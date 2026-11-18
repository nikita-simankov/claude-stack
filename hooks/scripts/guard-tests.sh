#!/usr/bin/env bash
# PreToolUse(Edit/Write): during the TDD GREEN phase test files are frozen.
# Phase comes from <project>/.claude-stack/tdd-phase (scripts/tdd-phase.sh), see lib.sh tdd_phase.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

root="$(project_dir)"
[[ "$(tdd_phase "$root")" == "green" ]] || exit 0

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
