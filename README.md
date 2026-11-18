# claude-stack

Личный переиспользуемый стек для Claude Code, оформленный как плагин и маркетплейс.

> Статус: каркас. Профиль — [docs/PROFILE.md](docs/PROFILE.md), план — [docs/BLUEPRINT.md](docs/BLUEPRINT.md).

## Структура

| Путь | Что там |
|---|---|
| `CLAUDE.md` | Мастер-промпт: глобальные правила (ставится в `~/.claude/CLAUDE.md`) |
| `skills/<name>/SKILL.md` | Навыки: workflow, которые Claude вызывает сам или через `/stack:<name>` |
| `agents/<name>.md` | Субагенты-специалисты |
| `hooks/hooks.json`, `hooks/scripts/` | Хуки: защита от опасных команд, автоформат, уведомления, контекст на старте |
| `output-styles/` | Стили ответа |
| `templates/` | Шаблоны: проектный `CLAUDE.md`, `settings.json`, `.mcp.json` |
| `scripts/` | `install.sh`, валидация |
| `.claude-plugin/` | Манифесты плагина и маркетплейса |

## Установка (черновик)

```
/plugin marketplace add nikita-simankov/claude-stack
/plugin install stack@claude-stack
```

Мастер-промпт и настройки ставятся отдельно через `scripts/install.sh` (плагины не умеют поставлять `CLAUDE.md`).
