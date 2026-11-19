#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
mkdir -p orders
cat > orders/handler.go <<'GO'
package orders

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

// GetOrder returns an order. Auth middleware puts the user id in the X-User-ID header.
func GetOrder(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.URL.Query().Get("id")
		row := db.QueryRow("SELECT id, user_id, total FROM orders WHERE id = '" + id + "'")
		var o struct {
			ID     string `json:"id"`
			UserID string `json:"user_id"`
			Total  int64  `json:"total"`
		}
		if err := row.Scan(&o.ID, &o.UserID, &o.Total); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		json.NewEncoder(w).Encode(o)
	}
}
GO
git add -A && git commit -qm base
