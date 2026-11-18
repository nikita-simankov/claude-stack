#!/usr/bin/env bash
# feature-base: print the commit the current feature branched from, for diffs and gate-scan.
# Order: merge-base with origin/HEAD, main, master. Prints HEAD when none is found or the
# base equals HEAD (working directly on the default branch). Always exits 0.
set -uo pipefail
head="$(git rev-parse HEAD 2>/dev/null)" || { echo HEAD; exit 0; }
for ref in origin/HEAD main master; do
  b="$(git merge-base HEAD "$ref" 2>/dev/null)" || continue
  [[ -n "$b" && "$b" != "$head" ]] && { echo "$b"; exit 0; }
done
echo HEAD
