# claude-stack

Личный рабочий стек для Claude Code: spec-driven разработка + строгий TDD, субагенты-специалисты, хуки-предохранители и жёсткий тон. Оформлен как плагин и маркетплейс — ставится в любом окружении одной командой.

Под кого собран: [docs/PROFILE.md](docs/PROFILE.md). Чертёж: [docs/BLUEPRINT.md](docs/BLUEPRINT.md).

## Установка

**1. Плагин** (навыки, агенты, хуки, стиль) — внутри Claude Code:

```
/plugin marketplace add nikita-simankov/claude-stack
/plugin install stack@claude-stack
```

**2. Мастер-промпт и настройки** (плагины не умеют ставить `CLAUDE.md`):

```bash
git clone https://github.com/nikita-simankov/claude-stack ~/claude-stack
```

```bash
~/claude-stack/scripts/install.sh
```

Скрипт делает `~/.claude/CLAUDE.md` симлинком на репо (обновление — `git pull`) и вливает `templates/settings.json` в `~/.claude/settings.json`: подключает маркетплейс, включает плагин, добавляет permissions. Твои существующие настройки сохраняются, бэкап рядом.

**3. Новый проект:**

```bash
~/claude-stack/scripts/install.sh --project /path/to/project
```

Создаёт проектный `CLAUDE.md` (заполни плейсхолдеры), `.mcp.json` (Context7, Postgres read-only, Playwright, GitHub read-only) и дописывает `.gitignore`. Для MCP нужны переменные окружения `DATABASE_URI_READONLY` и `GITHUB_PAT`.

## Как работать

```
/stack:spec <фича>   → docs/specs/<фича>/spec.md      ты утверждаешь
/stack:tasks         → docs/specs/<фича>/tasks.md     ты утверждаешь
/stack:tdd           → RED: падающий тест → СТОП, ты проверяешь тест
                     → GREEN: тесты заморожены хуком → REFACTOR → [x] в tasks.md
/stack:commit-msg    → готовые git-команды; коммитишь ты
```

Тупик: Claude сам идёт по лестнице `debugger` → `/stack:council` (5 ролей + синтез, `/stack:council 10 ...` вручную) → к тебе с фактами.
Новая сессия: хук сам подтягивает ветку, незакоммиченное, активную задачу и `HANDOFF.md`. Перед уходом — `/stack:handoff`.

## Состав

### Навыки (`skills/`)
| Навык | Что делает |
|---|---|
| `spec` | Опрос + спецификация фичи с проверяемыми критериями приёмки |
| `tasks` | Спека → задачи, у каждой тест-кейсы и покрытие AC |
| `tdd` | Один цикл red → стоп → green → refactor |
| `debug` | Воспроизвести → гипотезы → корень → регрессионный тест |
| `council` | Консилиум N ролей параллельно + один вердикт |
| `commit-msg` | Conventional Commit + команды для тебя |
| `catchup` | Восстановить контекст сессии |
| `handoff` | Записать `HANDOFF.md` |
| `new-skill` | Расширить этот стек в том же стиле |

### Субагенты (`agents/`)
| Агент | Модель | Доступ | Для чего |
|---|---|---|---|
| `code-reviewer` | opus | read-only | Независимое ревью диффа |
| `debugger` | opus | read + временные правки | Поиск первопричины |
| `security-auditor` | opus | read-only | Auth, ввод, SQL, секреты, вебхуки |
| `researcher` | sonnet | read + web | Документация и версии библиотек |
| `critic` | opus | read-only | Найти, почему план провалится |

### Хуки (`hooks/`)
| Хук | Что делает |
|---|---|
| `guard-git` | Блокирует любые пишущие git-команды; без `jq` и `python3` блокирует всё, а не пропускает. Чтение (`status/diff/log/show/blame`) разрешено. Выключить для проекта: `"env": {"STACK_ALLOW_GIT": "1"}` в его `.claude/settings.json` |
| `guard-secrets` | Не даёт читать/писать/искать (`Read/Edit/Write/Grep/Glob/Bash`) `.env*` (кроме `.env.example`), ключи, сертификаты; блокирует `rm -rf /~.*`, `curl \| sh`, дамп окружения, рекурсивный `grep` без `--exclude='.env*'`. `DROP/TRUNCATE/drizzle-kit push` — не блок, а вопрос тебе: на локальной БД это нормально |
| `guard-tests` | В фазе GREEN (`.claude-stack/tdd-phase`, пишет `scripts/tdd-phase.sh`) запрещает правку тест-файлов |
| `autoformat` | Biome / gofmt / rustfmt после каждой правки. Только формат, без lint-фиксов — иначе сносились бы импорты, которые Claude вот-вот использует |
| `session-context` | На старте: ветка, незакоммиченное, фаза TDD, активная задача, `HANDOFF.md` |

### Прочее
- `CLAUDE.md` — мастер-промпт: правила работы.
- Фаза TDD живёт в `.claude-stack/tdd-phase` (сам себя gitignore-ит), а не в `.claude/`: Claude Code не даёт писать в `.claude/` без подтверждения.
- `output-styles/mentor.md` — тон: жёсткий ментор, русский, минимум текста, спорит, код-примеры. Включается вместе с плагином; выключить — `/config` → Output style.
- `templates/` — проектный `CLAUDE.md`, `.mcp.json`, `settings.json`, `.gitignore`-сниппет.
- `scripts/validate.sh` + `tests/hooks.test.sh` + GitHub Action — манифесты, фронтматтер, shellcheck и ~150 регрессионных кейсов хуков, gate-scan и инъекций в навыках. Поведенческие eval-кейсы навыков и агентов — `evals/`, прогон `scripts/eval.sh '<name>-*'`, протокол и результаты — [docs/REWORK.md](docs/REWORK.md).

## Расширение

`/stack:new-skill <что нужно>` — Claude создаст компонент по конвенциям стека. После любой правки:

```bash
scripts/validate.sh
```

Стоимость: ~3.5k токенов постоянного контекста на сессию (`CLAUDE.md` + стиль ≈ 2k, описания навыков и агентов ≈ 1.6k); тела навыков грузятся только при вызове. Проверить: `claude plugin details stack@claude-stack`.

## Требования
`bash`, `jq` (или `python3` как запасной вариант для хуков). Для MCP-шаблона: `node`/`npx`, `uv`/`uvx`.
