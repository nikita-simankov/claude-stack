# Чертёж стека

## Основной цикл

```
/stack:spec  →  docs/specs/<фича>/spec.md      (требования, критерии приёмки, non-goals)
/stack:tasks →  docs/specs/<фича>/tasks.md     (задачи, у каждой — тест-кейсы)
/stack:tdd   →  RED (пишет падающий тест) → СТОП, ты проверяешь тест
             →  GREEN (тесты заморожены хуком) → REFACTOR → отметка в tasks.md
/stack:commit-msg (gate-scan по фиче + сообщение, коммитишь ты)
```

Тупик: `debugger` → `/stack:council` (5 ролей + синтезатор, `council 10` вручную).

## Мастер-промпт и тон
- `CLAUDE.md`: правила работы (spec → TDD, без git, проверка перед «готово», эскалация).
- `output-styles/mentor.md`: жёсткий ментор на русском, минимум текста, спорит, код-примеры, редкий мат. Включается автоматически вместе с плагином.

## Навыки (`skills/`)
| Навык | Назначение |
|---|---|
| `spec` | Опрашивает тебя и пишет спецификацию фичи |
| `tasks` | Режет спеку на задачи с тест-кейсами |
| `tdd` | Один цикл red → стоп → green → refactor |
| `debug` | Системная отладка: воспроизвести → гипотезы → корень → тест на баг |
| `council` | Консилиум N ролей + синтез в один вердикт |
| `commit-msg` | Conventional Commit сообщение по диффу (без коммита) |
| `catchup` | Восстановить контекст: дифф, активная спека, HANDOFF |
| `handoff` | Записать HANDOFF.md для следующей сессии |
| `research` | Технический ресёрч: библиотеки, API, подходы — с источниками и выводом |
| `new-skill` | Расширять сам стек: новый навык/агент в том же стиле |

## Субагенты (`agents/`)
`architect`, `code-reviewer`, `debugger`, `test-writer`, `security-auditor`, `researcher`, `doc-writer`, `critic`.
Роли консилиума описаны внутри навыка `council`, отдельными файлами не плодятся.

## Хуки (`hooks/`)
| Хук | Событие | Что делает |
|---|---|---|
| `guard-git` | PreToolUse · Bash | Блокирует add/commit/push/reset/rebase/merge/checkout/stash/tag/… Чтение (status/diff/log/show/blame) разрешено |
| `guard-secrets` | PreToolUse · Read/Edit/Write/Bash | Блок `.env*`, ключей, `*.pem`; `rm -rf /~`, `curl \| sh`, `DROP/TRUNCATE` |
| `guard-tests` | PreToolUse · Edit/Write | В фазе GREEN запрещает править тест-файлы |
| `autoformat` | PostToolUse · Edit/Write | Biome / gofmt / rustfmt, если есть в проекте |
| `session-context` | SessionStart | Ветка, git status, активная спека и задача, HANDOFF.md |

## Шаблоны (`templates/`)
- `project-CLAUDE.md` — проектная память под TS/Go/Rust (команды pnpm/biome/go/cargo).
- `mcp.json` — Context7, Postgres read-only, Playwright, GitHub read-only.
- `settings.json` — permissions: разрешены тесты/линт/билд, запрещены секреты.

## Установка и поддержка
- Плагин: `/plugin marketplace add nikita-simankov/claude-stack` → `/plugin install stack@claude-stack`.
- `scripts/install.sh`: `CLAUDE.md` и `settings.json` в `~/.claude` (с бэкапом).
- `scripts/validate.sh` + GitHub Action: валидация манифестов, фронтматтера и shellcheck хуков.
