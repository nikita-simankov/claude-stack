#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
mkdir -p payments
cat > payments/webhook.go <<'GO'
package payments

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type Event struct {
	ID      string `json:"id"`
	OrderID string `json:"order_id"`
	Amount  int64  `json:"amount"`
}

// Handler marks the order paid. The provider retries deliveries up to 5 times and may deliver concurrently.
func Handler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var e Event
		if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
			http.Error(w, "bad event", http.StatusBadRequest)
			return
		}
		if _, err := db.Exec(`UPDATE orders SET paid_total = paid_total + $1 WHERE id = $2`, e.Amount, e.OrderID); err != nil {
			http.Error(w, "db", http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}
GO
git add -A && git commit -qm "feat(payments): webhook"
