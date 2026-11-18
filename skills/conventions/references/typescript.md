# TypeScript stack

## Language
- `strict: true`. No `any` (use `unknown` + narrowing); no non-null `!` without a comment on why it is safe.
- Prefer `type` for unions/data, `interface` only for extendable object contracts if the project does.
- Validate every external input with zod at the boundary (tRPC input, env, webhooks, JSON from Redis). Infer types from schemas: `type X = z.infer<typeof X>`.
- Errors: throw typed errors (`TRPCError` with the right `code` at the API edge); never return `null` to mean "error".
- Env: one validated `env.ts` module; never read `process.env` elsewhere.

## Next.js (App Router)
- Server Components by default; `"use client"` only for interactivity, as low in the tree as possible.
- Never import server-only modules (db, secrets) into client components; use `import "server-only"`.
- Data mutations through tRPC or Server Actions consistently — follow whichever the project uses.
- Respect runtime: no Node APIs in `edge` routes/middleware.

## tRPC + React Query
- Procedures: `input(zodSchema)`, auth via middleware (`protectedProcedure`), business logic in a service layer, not in the router.
- Query keys come from tRPC helpers; invalidate precisely (`utils.foo.list.invalidate()`), not globally.
- Optimistic updates: `onMutate` snapshot → `onError` rollback → `onSettled` invalidate.
- Never fetch in `useEffect` what React Query can fetch.

## Drizzle
- Schema is the source of truth; generate migrations with `drizzle-kit generate`, review the SQL, never edit applied migrations.
- Multi-statement writes in `db.transaction(async (tx) => …)` and use `tx` inside, not `db`.
- Select only needed columns for hot paths; watch for N+1 (use joins or `with` relational queries).

## Testing (Vitest)
- Co-locate `*.test.ts` next to the code. `describe` per unit, `it("does X when Y")`.
- Test tRPC procedures through `createCaller` with a real test DB (transaction rollback or truncate per test) rather than mocking Drizzle.
- Mock only at process boundaries (HTTP to third parties, clock, randomness). `vi.useFakeTimers()` for time.
- React: Testing Library, query by role/label, assert what the user sees.

```ts
it("rejects upgrade when plan is unknown", async () => {
  const caller = appRouter.createCaller(await ctxFor(user));
  await expect(caller.billing.upgrade({ planId: "nope" }))
    .rejects.toMatchObject({ code: "NOT_FOUND" });
});
```
