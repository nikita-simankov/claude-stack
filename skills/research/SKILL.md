---
name: research
description: Technical research with sources — library and API usage, version differences, comparing approaches or tools, migration paths, known bugs. Use when the user asks "как правильно", "что выбрать", "сравни", "research", "изучи", or before using an API you have not verified in this codebase.
argument-hint: "<question>"
---

# research

Answer a technical question with evidence, not memory.

1. **Pin versions.** Read `package.json`/lockfile, `go.mod`, `Cargo.toml`, Dockerfiles. Research the versions actually used.
2. **Sources, in order of trust:** this codebase (how it is already done) → official docs via Context7 MCP when available → source code / types in `node_modules`, Go module cache, `~/.cargo/registry` → changelogs and release notes → GitHub issues → web articles (last resort, check the date).
3. For broad questions (many sources, several candidates) delegate to the `researcher` subagent with the pinned versions and the exact question.
4. **Compare** candidates on what matters for this project: fit with the existing stack, maintenance, performance, type safety, operational cost, lock-in.

## Output
```
Ответ: <recommendation in 1-3 lines>
Почему: <key reasons, bullets>
Пример: <minimal code for this project's stack>
Не подходит: <rejected options + one-line reason>
Источники: <links or file paths, with version>
Неуверенность: <what was not verified>
```
