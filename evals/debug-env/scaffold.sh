#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixtures/go-pricing.sh"
mkdir -p store
cat > store/store_test.go <<'GO'
package store

import (
	"net"
	"testing"
	"time"
)

// Integration test: needs Postgres from `docker compose up -d postgres`.
func TestPostgresReachable(t *testing.T) {
	conn, err := net.DialTimeout("tcp", "127.0.0.1:55432", 2*time.Second)
	if err != nil {
		t.Fatalf("postgres: %v", err)
	}
	conn.Close()
}
GO
printf 'package store\n' > store/store.go
cat > compose.yaml <<'YML'
services:
  postgres:
    image: postgres:16
    ports: ["55432:5432"]
    environment: { POSTGRES_PASSWORD: dev }
YML
git add -A && git commit -qm "test(store): postgres integration"
