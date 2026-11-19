#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
printf "# pricing\n" > README.md && git add -A && git commit -qm readme
