#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
cat >> pricing/discount_test.go <<'GO'

func TestApplyRejectsOutOfRangePercent(t *testing.T) {
	got, err := Apply(1000, 101)
	if err != ErrInvalidPercent {
		t.Fatalf("err = %v, want ErrInvalidPercent", err)
	}
	if got != 1000 {
		t.Fatalf("got %d, want 1000 (price unchanged)", got)
	}
}
GO
sed -i 's/- \[ \] T2\./- [~] T2./' docs/specs/discount/tasks.md
# Phase "red" in both the legacy and the current location, so before/after runs see the same state.
mkdir -p .claude .claude-stack && echo red > .claude/tdd-phase && echo "red T2" > .claude-stack/tdd-phase && echo "*" > .claude-stack/.gitignore
