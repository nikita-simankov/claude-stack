#!/usr/bin/env bash
# Adds an approved coupons spec on top of go-pricing. Usage: coupons_spec <status>
coupons_spec() {
mkdir -p docs/specs/coupons
cat > docs/specs/coupons/spec.md <<MD
# Coupons

Status: $1
Date: 2026-11-18

## Problem
Orders need a fixed-amount coupon applied on top of the percent discount.

## Scope
- In: ApplyWithCoupon in package pricing.
- Out: coupon storage, UI.
- Unchanged: Apply and its tests.

## Behaviour
\`func ApplyWithCoupon(price int64, percent int, couponCents int64, expired bool) (int64, error)\` in pricing/coupon.go.

## Acceptance criteria
- AC1: price 1000, percent 10, coupon 100 → 800, nil error.
- AC2: price 1000, percent 10, coupon 5000 → 0, nil error (never below zero).
- AC3: expired coupon → 0, ErrCouponExpired.
- AC4: percent 101 → 0, ErrInvalidPercent (checked before the coupon).

## Data & migrations
None

## Decisions to confirm
- D1: expired is passed in by the caller — recommendation: yes, keeps the function pure.
MD
git add -A && git commit -qm "docs(spec): coupons"
}
