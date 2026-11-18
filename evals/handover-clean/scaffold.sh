#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
cat > pricing/discount.go <<'GO'
package pricing

import "errors"

// ErrInvalidPercent is returned when a discount percent is outside 0..100.
var ErrInvalidPercent = errors.New("invalid percent")

// Apply returns price reduced by percent. Prices are in cents.
func Apply(price int64, percent int) (int64, error) {
	if percent < 0 || percent > 100 {
		return 0, ErrInvalidPercent
	}
	return price - price*int64(percent)/100, nil
}
GO
cat >> pricing/discount_test.go <<'GO'

func TestApplyRejectsOutOfRangePercent(t *testing.T) {
	for _, p := range []int{-1, 101} {
		got, err := Apply(1000, p)
		if err != ErrInvalidPercent || got != 0 {
			t.Fatalf("percent %d: got %d, %v", p, got, err)
		}
	}
}
GO
sed -i 's/- \[ \] T2\./- [x] T2./' docs/specs/discount/tasks.md
