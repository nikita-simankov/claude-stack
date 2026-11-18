#!/usr/bin/env bash
# Run the stack's eval suite (claude plugin eval) with the grants our cases need.
#   scripts/eval.sh                    all cases
#   scripts/eval.sh 'tdd-*' [extra]    cases matching a glob, extra flags passed through
# Env: EVAL_MODEL (default claude-opus-5-5), EVAL_RUNS (default 3), EVAL_MAX_COST (default 5).
# Needs a sandbox backend for Bash (Linux: bubblewrap + socat).
set -euo pipefail
cd "$(dirname "$0")/.."
case_glob="${1:-*}"; shift || true
exec claude plugin eval . \
  --case "$case_glob" \
  --scaffold --trust-plugin --no-publish \
  --allow-tools Bash Edit Write \
  --model "${EVAL_MODEL:-claude-opus-5-5}" \
  --runs "${EVAL_RUNS:-3}" \
  --max-cost-usd "${EVAL_MAX_COST:-5}" \
  "$@"
