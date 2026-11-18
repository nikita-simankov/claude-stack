---
name: spec
description: Write a feature specification before any code. Use when the user asks for a new feature, a non-trivial change, a new endpoint/page/service, or says "spec", "спека", "спецификация", "давай спланируем", "новая фича". Interviews the user, then writes docs/specs/<feature>/spec.md.
argument-hint: "<feature name or short description>"
---

# spec

Goal: a spec the user approves, small enough to implement, precise enough to derive tests from.

## Steps

1. **Ground yourself first.** Read the code the feature touches: entry points, data model (Drizzle schema / migrations / proto files), existing similar features, tests. Do not ask the user what the code can tell you.
2. **Interview.** Ask only what the code cannot answer, in one batch (use AskUserQuestion when available, 2-4 options each, your recommendation first):
   - the user-visible behaviour and the main scenario;
   - edge cases and failure modes that matter;
   - constraints: performance, compatibility, security, deadlines;
   - what is explicitly out of scope.
   Push back on scope creep and vague requirements. If the idea itself is weak, say so before writing anything.
3. **Write** `docs/specs/<feature-kebab>/spec.md` using the template below. Every acceptance criterion must be testable (Given/When/Then or an input→output table).
4. **Optional critique.** For risky or cross-cutting specs, run the `critic` subagent on the draft and fold in what holds up.
5. **Stop.** Show the path and a 3-5 line summary. Wait for approval. On approval, suggest the `tasks` skill.

## Template

```markdown
# <Feature>

Status: draft | approved
Owner: <user>  ·  Date: <YYYY-MM-DD>

## Problem
<Why this exists. 2-4 sentences.>

## Scope
- In: ...
- Out (non-goals): ...

## Behaviour
<Main flow. Interfaces: tRPC procedures / HTTP / gRPC methods / UI states, with signatures.>

## Acceptance criteria
- AC1: Given ..., when ..., then ...
- AC2: ...

## Edge cases & errors
| Case | Expected |
|---|---|

## Data & migrations
<Schema changes, Drizzle migration, backfill, Redis keys/TTL. "None" if none.>

## Risks & open questions
- ...
```

Keep it short. A spec longer than ~2 screens usually means the feature should be split.
