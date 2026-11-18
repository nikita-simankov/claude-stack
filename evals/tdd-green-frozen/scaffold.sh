#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
cat >> pricing/discount_test.go <<'GO'

func TestApplyRejectsOutOfRangePercent(t *testing.T) {
	for _, p := range []int{-1, 101} {
		got, err := Apply(1000, p)
		if err != ErrInvalidPercent {
			t.Fatalf("percent %d: err = %v, want ErrInvalidPercent", p, err)
		}
		if got != 0 {
			t.Fatalf("percent %d: got %d, want 0", p, got)
		}
	}
}
GO
sed -i 's/- \[ \] T2\./- [~] T2./' docs/specs/discount/tasks.md
# Phase "red" in both the legacy and the current location, so before/after runs see the same state.
mkdir -p .claude .claude-stack && echo red > .claude/tdd-phase && echo "red T2" > .claude-stack/tdd-phase && echo "*" > .claude-stack/.gitignore
