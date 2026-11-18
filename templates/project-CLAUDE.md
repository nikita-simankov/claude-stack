# <Project name>

<One paragraph: what this is, who uses it, what matters most (latency? correctness? cost?).>

## Layout
- `apps/web` — Next.js (App Router), tRPC client, React Query
- `apps/api` / `packages/api` — tRPC routers → services → Drizzle
- `services/<name>` — Go/Rust services, gRPC (`proto/`, `buf`)
- `packages/db` — Drizzle schema + migrations
- `docs/specs/` — feature specs and tasks (spec → tasks → TDD)

## Commands
| Purpose | Command |
|---|---|
| Install | `pnpm install` |
| Dev | `docker compose up -d postgres redis && pnpm dev` |
| Test (unit) | `pnpm vitest run <file>` · all: `pnpm test` |
| Test (e2e) | `pnpm playwright test <file>` |
| Typecheck | `pnpm tsc --noEmit` |
| Lint/format | `pnpm biome check --write <files>` |
| Migrations | `pnpm drizzle-kit generate` → review SQL → `pnpm drizzle-kit migrate` (local only) |
| Go | `go test ./... -race` · `go vet ./...` |
| Rust | `cargo test` · `cargo clippy --all-targets -- -D warnings` |
| Proto | `buf lint && buf generate` |

## Project rules
- <Conventions that differ from the global stack defaults.>
- <Where business logic lives; what must never be imported where.>
- <Test DB setup: how tests get a clean database.>

## Gotchas
- <Things that waste an hour if you don't know them.>
