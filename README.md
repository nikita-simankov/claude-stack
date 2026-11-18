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
/stack:self-review   → проверка диффа
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
| `self-review` | Ревью своего диффа по чеклисту |
| `commit-msg` | Conventional Commit + команды для тебя |
| `catchup` | Восстановить контекст сессии |
| `handoff` | Записать `HANDOFF.md` |
| `conventions` | Правила стека: TS/Next/tRPC/React Query/Drizzle/Biome/pnpm, Go, Rust, gRPC, Postgres, Redis, Docker |
| `research` | Технический ресёрч под версии проекта, с источниками |
| `new-skill` | Расширить этот стек в том же стиле |

### Субагенты (`agents/`)
| Агент | Модель | Доступ | Для чего |
|---|---|---|---|
| `architect` | opus | read-only | Варианты дизайна, контракты, схема данных |
| `test-writer` | sonnet | пишет тесты | RED-фаза по тест-кейсам задачи |
| `code-reviewer` | opus | read-only | Независимое ревью диффа |
| `debugger` | opus | read + временные правки | Поиск первопричины |
| `security-auditor` | opus | read-only | Auth, ввод, SQL, секреты, вебхуки |
| `researcher` | sonnet | read + web | Документация и версии библиотек |
| `doc-writer` | sonnet | только доки | README, ADR, API-доки |
| `critic` | opus | read-only | Найти, почему план провалится |

### Хуки (`hooks/`)
| Хук | Что делает |
|---|---|
| `guard-git` | Блокирует любые пишущие git-команды. Чтение (`status/diff/log/show/blame`) разрешено. Выключить для проекта: `"env": {"STACK_ALLOW_GIT": "1"}` в его `.claude/settings.json` |
| `guard-secrets` | Не даёт читать/писать `.env*` (кроме `.env.example`), ключи, сертификаты; блокирует `rm -rf /~.*`, `curl \| sh`, `DROP/TRUNCATE`, дамп окружения |
| `guard-tests` | В фазе GREEN (`.claude/tdd-phase`) запрещает правку тест-файлов |
| `autoformat` | Biome / gofmt / rustfmt после каждой правки. Только формат, без lint-фиксов — иначе сносились бы импорты, которые Claude вот-вот использует |
| `session-context` | На старте: ветка, незакоммиченное, фаза TDD, активная задача, `HANDOFF.md` |

### Прочее
- `CLAUDE.md` — мастер-промпт: правила работы.
- `output-styles/mentor.md` — тон: жёсткий ментор, русский, минимум текста, спорит, код-примеры. Включается вместе с плагином; выключить — `/config` → Output style.
- `templates/` — проектный `CLAUDE.md`, `.mcp.json`, `settings.json`, `.gitignore`-сниппет.
- `scripts/validate.sh` + `tests/hooks.test.sh` + GitHub Action — манифесты, фронтматтер, shellcheck и 60+ регрессионных кейсов хуков.

## Расширение

`/stack:new-skill <что нужно>` — Claude создаст компонент по конвенциям стека. После любой правки:

```bash
scripts/validate.sh
```

Стоимость: ~1.9k токенов постоянного контекста на сессию (описания навыков и агентов); тела грузятся только при вызове. Проверить: `claude plugin details stack@claude-stack`.

## Требования
`bash`, `jq` (или `python3` как запасной вариант для хуков). Для MCP-шаблона: `node`/`npx`, `uv`/`uvx`.
