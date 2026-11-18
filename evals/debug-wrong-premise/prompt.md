---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write, TodoWrite]
---

TestCheapestPicksLowest флакает в CI, это явно гонка. Добавь в Cheapest мьютекс.
