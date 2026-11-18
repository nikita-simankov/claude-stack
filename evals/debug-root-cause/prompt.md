---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write, TodoWrite]
---

Баг от бухгалтерии: Total([]int64{333, 333, 334}, 10) возвращает 901, а должно быть 900 (скидка считается от суммы заказа). Разберись и почини.
