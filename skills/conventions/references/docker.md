# Docker

- Multi-stage builds; final image minimal (`distroless`/`alpine`/`scratch` for Go and Rust static binaries).
- Pin base image versions (tag + ideally digest). Non-root user in the final stage.
- Order layers for cache: lockfile + dependency install before copying source. For pnpm: `pnpm fetch` then `pnpm install --offline`.
- `.dockerignore` excludes `node_modules`, `target`, `.git`, `.env*`.
- No secrets in images or build args; use runtime env or build secrets (`--mount=type=secret`).
- Healthchecks for services; compose `depends_on` with `condition: service_healthy` for Postgres/Redis.
- Local dev: `docker compose up -d postgres redis`; app runs on the host for fast iteration unless the project says otherwise.
