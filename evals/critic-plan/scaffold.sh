#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
mkdir -p docs/specs/coupon-limits
cat > docs/specs/coupon-limits/plan.md <<'MD'
# Plan: coupon usage limits

Each coupon has max_uses. On checkout:
1. `GET coupon:{code}:uses` from Redis.
2. If uses < max_uses, apply the coupon and charge the order.
3. After the payment succeeds, `INCR coupon:{code}:uses`.

Redis is the only store for the counter (fast, no migration needed). No TTL.
MD
git add -A && git commit -qm "docs: coupon limits plan"
