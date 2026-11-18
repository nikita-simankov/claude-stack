---
name: conventions
description: Default engineering conventions for the user's stack — TypeScript (pnpm, Biome, Vitest, Next.js, React, React Query, tRPC, Drizzle), Go, Rust, gRPC, Postgres, Redis, Docker. Use when writing or reviewing code in these technologies, choosing test/lint/build commands, designing schemas, or when unsure how something "should" be done here.
---

# conventions

Precedence: **the project's own code and CLAUDE.md > these defaults**. Never "fix" an established project convention to match this file; follow it and mention the difference if it matters.

## Detect the toolchain first
| Signal | Use |
|---|---|
| `pnpm-lock.yaml` | `pnpm` (never npm/yarn); workspaces → `pnpm --filter <pkg>` |
| `biome.json(c)` | `pnpm biome check --write <files>`; no ESLint/Prettier unless configured |
| `vitest.config.*` or `vitest` in deps | `pnpm vitest run <file>`; else the `test` script |
| `playwright.config.*` | `pnpm playwright test <file>` for e2e |
| `go.mod` | `go test ./... -race`, `go vet ./...`, `gofmt`/`goimports`; `golangci-lint run` if configured |
| `Cargo.toml` | `cargo test`, `cargo clippy --all-targets -- -D warnings`, `cargo fmt` |
| `*.proto` + `buf.yaml` | `buf lint`, `buf generate`; never hand-edit generated code |
| `drizzle.config.*` | `pnpm drizzle-kit generate` for migrations; never edit applied migrations |
| `docker-compose.yml`/`compose.yaml` | local Postgres/Redis via `docker compose up -d <svc>` |

Typecheck TS with `pnpm tsc --noEmit` (or the project's `typecheck` script).

## References (read the one you need)
- `references/typescript.md` — TS, Next.js, React, React Query, tRPC, Drizzle, testing
- `references/go.md` — Go services, errors, context, testing, gRPC
- `references/rust.md` — Rust services, errors, async, testing
- `references/data.md` — Postgres, migrations, Redis
- `references/docker.md` — images, compose, local dev
