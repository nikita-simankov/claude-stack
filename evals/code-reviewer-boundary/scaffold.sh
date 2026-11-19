#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
python3 - <<'PY'
p='pricing/discount.go'; s=open(p).read()
s=s.replace("\treturn price - price*int64(percent)/100, nil","\tif percent < 0 || percent >= 100 {\n\t\treturn 0, ErrInvalidPercent\n\t}\n\treturn price - price*int64(percent)/100, nil")
open(p,'w').write(s)
PY
cat >> pricing/discount_test.go <<'GO'

func TestApplyRejectsOutOfRangePercent(t *testing.T) {
	for _, p := range []int{-1, 101} {
		if got, err := Apply(1000, p); err != ErrInvalidPercent || got != 0 {
			t.Fatalf("percent %d: got %d, %v", p, got, err)
		}
	}
}
GO
sed -i 's/- \[ \] T2\./- [x] T2./' docs/specs/discount/tasks.md
