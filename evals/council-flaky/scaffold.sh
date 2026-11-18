#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
cat > pricing/cheapest.go <<'GO'
package pricing

// Cheapest returns the SKU with the lowest price.
func Cheapest(prices map[string]int64) string {
	best, bestPrice := "", int64(-1)
	for sku, p := range prices {
		if bestPrice < 0 || p < bestPrice {
			best, bestPrice = sku, p
		}
	}
	return best
}
GO
cat > pricing/cheapest_test.go <<'GO'
package pricing

import "testing"

func TestCheapestPicksLowest(t *testing.T) {
	got := Cheapest(map[string]int64{"apple": 100, "banana": 100, "cherry": 300})
	if got != "apple" {
		t.Fatalf("got %q, want apple", got)
	}
}
GO
git add -A && git commit -qm "feat(pricing): cheapest sku"
