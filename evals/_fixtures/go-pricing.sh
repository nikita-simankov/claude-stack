#!/usr/bin/env bash
# Shared scaffold: a small Go module "pricing" with one tested function, a spec and a task list.
# Source it from a case's scaffold script, then layer case-specific state on top.
set -euo pipefail
git init -q && git config user.email dev@example.com && git config user.name dev
cat > go.mod <<'MOD'
module example.com/pricing

go 1.22
MOD
mkdir -p pricing docs/specs/discount
cat > pricing/discount.go <<'GO'
package pricing

import "errors"

// ErrInvalidPercent is returned when a discount percent is outside 0..100.
var ErrInvalidPercent = errors.New("invalid percent")

// Apply returns price reduced by percent. Prices are in cents.
func Apply(price int64, percent int) (int64, error) {
	return price - price*int64(percent)/100, nil
}
GO
cat > pricing/discount_test.go <<'GO'
package pricing

import "testing"

func TestApplyTenPercent(t *testing.T) {
	got, err := Apply(1000, 10)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != 900 {
		t.Fatalf("got %d, want 900", got)
	}
}
GO
cat > docs/specs/discount/spec.md <<'MD'
# Discount

Status: approved

## Acceptance criteria
- AC1: Given percent 10 and price 1000, when Apply runs, then it returns 900.
- AC2: Given a percent below 0 or above 100, when Apply runs, then it returns ErrInvalidPercent and price 0.
MD
cat > docs/specs/discount/tasks.md <<'MD'
# Tasks: Discount

Spec: ./spec.md

- [x] T1. Apply reduces price by percent  (AC1)
  - Files: `pricing/discount.go`, test `pricing/discount_test.go`
- [ ] T2. Apply rejects percent outside 0..100  (AC2)
  - Files: `pricing/discount.go`, test `pricing/discount_test.go`
  - Tests:
    - percent -1 returns ErrInvalidPercent and 0
    - percent 101 returns ErrInvalidPercent and 0
MD
printf 'HANDOFF.md\n.claude/tdd-phase\n' > .gitignore
git add -A && git commit -qm "feat(pricing): apply percent discount"
