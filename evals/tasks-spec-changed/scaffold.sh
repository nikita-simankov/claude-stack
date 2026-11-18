#!/usr/bin/env bash
set -euo pipefail
d="$(dirname "${BASH_SOURCE[0]}")/../_fixtures"; source "$d/go-pricing.sh"; source "$d/coupons-spec.sh"; coupons_spec approved
cat > docs/specs/coupons/tasks.md <<'MD'
# Tasks: Coupons

Spec: ./spec.md

- [x] T1. ApplyWithCoupon subtracts the coupon after the percent discount  (AC1)
  - Files: `pricing/coupon.go`, test `pricing/coupon_test.go`
  - Tests:
    - 1000, 10%, coupon 100 → 800
- [ ] T2. Result never goes below zero  (AC2)
  - Tests:
    - 1000, 10%, coupon 5000 → 0
- [ ] T3. Expired coupon is rejected  (AC3)
  - Tests:
    - expired → 0, ErrCouponExpired
- [ ] T4. Invalid percent is checked first  (AC4)
  - Tests:
    - percent 101 → 0, ErrInvalidPercent
MD
git add -A && git commit -qm "docs(tasks): coupons"
python3 - <<'PY'
p='docs/specs/coupons/spec.md'; s=open(p).read()
s=s.replace('- AC3: expired coupon → 0, ErrCouponExpired.','- AC3 (superseded by AC5, 2026-11-19): expired coupon → 0, ErrCouponExpired.')
s=s.replace('- AC4: percent 101 → 0, ErrInvalidPercent (checked before the coupon).','- AC4: percent 101 → 0, ErrInvalidPercent (checked before the coupon).\n- AC5: expired coupon → price after the percent discount without the coupon, ErrCouponExpired (the order still goes through).')
s=s.replace('## Decisions to confirm','## Changes\n- 2026-11-19: AC3 superseded by AC5 — an expired coupon no longer zeroes the price (user).\n\n## Decisions to confirm')
open(p,'w').write(s)
PY
