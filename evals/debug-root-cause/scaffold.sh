#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
cat > pricing/total.go <<'GO'
package pricing

// Total returns the order total after a percent discount. Prices are in cents.
func Total(items []int64, percent int) (int64, error) {
	var sum int64
	for _, p := range items {
		d, err := Apply(p, percent)
		if err != nil {
			return 0, err
		}
		sum += d
	}
	return sum, nil
}
GO
git add -A && git commit -qm "feat(pricing): order total"
