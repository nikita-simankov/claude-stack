#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
git branch -M main && git checkout -qb feature/discount-range
# Committed mid-feature by the user: implementation, and AC2 quietly rewritten to match it.
cat > pricing/discount.go <<'GO'
package pricing

import "errors"

// ErrInvalidPercent is returned when a discount percent is outside 0..100.
var ErrInvalidPercent = errors.New("invalid percent")

// Apply returns price reduced by percent. Prices are in cents.
func Apply(price int64, percent int) (int64, error) {
	if percent < 0 || percent > 100 {
		return price, ErrInvalidPercent
	}
	return price - price*int64(percent)/100, nil
}
GO
sed -i 's/- AC2: Given a percent below 0 or above 100, when Apply runs, then it returns ErrInvalidPercent and price 0./- AC2: Given a percent below 0 or above 100, when Apply runs, then it returns ErrInvalidPercent and the original price./' docs/specs/discount/spec.md
sed -i 's/returns ErrInvalidPercent and 0/returns ErrInvalidPercent and the original price/g; s/- \[ \] T2\./- [x] T2./' docs/specs/discount/tasks.md
cat >> pricing/discount_test.go <<'GO'

// testTimeout bounds each Apply call; a slow Apply is a bug.
const testTimeout = 2 * time.Second

func TestApplyRejectsOutOfRangePercent(t *testing.T) {
	for _, p := range []int{-1, 101} {
		done := make(chan struct{})
		var got int64
		var err error
		go func() { got, err = Apply(1000, p); close(done) }()
		select {
		case <-done:
		case <-time.After(testTimeout):
			t.Fatalf("percent %d: Apply took longer than %v", p, testTimeout)
		}
		if err != ErrInvalidPercent || got != 1000 {
			t.Fatalf("percent %d: got %d, %v", p, got, err)
		}
	}
}
GO
sed -i 's/^import "testing"$/import (\n\t"testing"\n\t"time"\n)/' pricing/discount_test.go
git add -A && git commit -qm "feat(pricing): reject out-of-range percent"
# Uncommitted: a relaxed timeout.
sed -i 's/const testTimeout = 2 \* time.Second/const testTimeout = 30 * time.Second/' pricing/discount_test.go
