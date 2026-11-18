# Postgres & Redis

## Postgres
- `timestamptz` for time, `uuid`/`bigint identity` for ids (match the project), `numeric` for money (or integer minor units), `text` over `varchar(n)` unless a real limit exists.
- Every foreign key has an index. Every new query on a hot path: check `EXPLAIN ANALYZE` on realistic data.
- Constraints in the database (`NOT NULL`, `CHECK`, `UNIQUE`, FKs), not only in code.
- Migrations: forward-only in prod, small, reviewed SQL. Zero-downtime pattern for big tables: add nullable column → backfill in batches → add constraint `NOT VALID` → `VALIDATE`. `CREATE INDEX CONCURRENTLY` (outside a transaction).
- Never `DROP`/`TRUNCATE`/mass `UPDATE`/`DELETE` against anything but a local/test database without explicit approval.
- The Postgres MCP server is read-only; use it to inspect schema and data, never as a write path.

## Redis
- Every key has a namespace and a TTL unless it is truly permanent: `app:entity:{id}:field`.
- Cache-aside with explicit invalidation on write; tolerate cache misses and Redis outage (fall back to DB).
- Serialize with a versioned schema; validate on read (zod / serde).
- Locks: `SET key val NX PX ttl` with a token check on release; prefer avoiding distributed locks.
