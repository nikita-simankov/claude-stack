# Исследование: prompt engineering + gstack → улучшения claude-stack

Дата: 2026-11-18. Бриф для консилиумов, которые перерабатывают навыки и агентов.

## Источники

**Anthropic (первоисточники):**
- Prompting best practices: platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Prompting Claude Opus 5 / Opus 5.5 / Fable 5.2 (model-specific guides, там же)
- Skill authoring best practices: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Effective context engineering for AI agents: anthropic.com/engineering/effective-context-engineering-for-ai-agents
- How we built our multi-agent research system: anthropic.com/engineering/multi-agent-research-system
- Claude Code docs: sub-agents, hooks, skills (code.claude.com/docs/en/…); `claude plugin eval --help`

**gstack** (github.com/garrytan/gstack, HEAD 44170d6, 5159 файлов): ETHOS.md, ARCHITECTURE.md, write-skill (+ references/diet.md), общая преамбула навыков, review (review-army, specialists/*, gate-integrity.md), verify, test-audit (test value bar), spec, context-save/learn, careful/freeze, plan-eng-review, autoplan (decision principles), model-overlays, docs/model-policy.md.

## Ключевые выводы: prompt engineering для текущих моделей Claude

1. **Объясняй «почему».** Правило с причиной обобщается лучше голого запрета («NEVER use ellipses» хуже, чем «ответ читает TTS, поэтому без многоточий»).
2. **Не кричи.** На Opus 4.5+ агрессивные «CRITICAL / You MUST» вызывают overtriggering. Нормальный тон: «Use X when…».
3. **«Never» — абсолют** (Fable 5.2). Модель следует ему буквально, и осторожность копится. Лучше писать правило с областью действия и причиной («спроси перед удалением файлов» вместо «никогда не удаляй»).
4. **Не проси перепроверять.** Opus 5+ сам проверяет и исправляет свою работу. Инструкции вида «double-check», «добавь шаг верификации», «проверь субагентом» дают over-verification без выигрыша в качестве. Это не то же самое, что требование реально запустить тесты: прогон тестов — это доказательство, а не перепроверка.
5. **Ревью: проси всё, фильтруй потом.** Если ревьюеру сказать «только серьёзное» или «будь консервативен», он буквально найдёт меньше. Правильно: все находки с severity и confidence, отбор отдельным проходом.
6. **Scope.** Opus 5 любит расширять задачу. Нужна явная рамка: «делай то, что просили, в задуманном объёме; если запрос кажется ошибочным, скажи одной фразой и делай как просили».
7. **Ownership.** Фраза «ты владелец кода» резко увеличивает рефакторинг и дописывание. Код пользователя → эту фразу не добавлять.
8. **Субагенты — по делу.** Opus 5 и Fable 5.2 делегируют охотно. Делегировать стоит только крупные независимые параллельные куски; не нужно делегировать то, что делается за несколько tool calls, и не нужно делегировать проверку собственной работы.
9. **Бриф субагенту:** цель, формат вывода, какие инструменты и источники, границы задачи. Короткий бриф → дублирование и дыры. Простая задача — 1 агент, сравнение — 2–4, сложное исследование — больше. Мультиагентная работа стоит ~15× токенов чата.
10. **Отчёт для читателя без контекста.** Ключевое в первых строках, никаких терминов, придуманных по ходу работы; читатель не видел tool calls.
11. **Никаких «пиши своё рассуждение в ответе».** На Opus 5+/Fable такое может отклоняться (`reasoning_extraction`). Просить можно короткое объяснение ответа или сводку действий.
12. **Защита от подгонки под тесты:** «Tests verify correctness, not define the solution… If any tests are incorrect, inform me rather than working around them».
13. **Против галлюцинаций:** «Never speculate about code you have not opened».
14. **Навыки:** description в третьем лице, что + когда, с ключевыми словами (≤1536 символов вместе с `when_to_use`). SKILL.md < 500 строк, references на один уровень вглубь, у reference длиннее 100 строк — оглавление. Чеклист, который модель копирует и отмечает. Петли «проверка → исправление → повтор». Единая терминология. Хрупкие операции — в скрипты (низкая свобода), суждение — текстом (высокая свобода).
15. **Сначала evals:** 3+ сценария → базовый прогон без навыка → минимальные инструкции → итерация. «Claude A пишет, Claude B проверяет на реальных задачах».
16. **Context engineering:** контекст — бюджет. Минимальный промпт, правки по наблюдаемым провалам. Just-in-time загрузка, структурированные заметки вне контекста.

## Возможности Claude Code, которые мы не используем

- **Навыки:** `!`cmd`` / ```` ```! ```` — инъекция вывода команды до старта навыка (git status, diff, фаза TDD); `${CLAUDE_SKILL_DIR}` для скриптов; `when_to_use`; `paths` (автоактивация по glob); `context: fork` + `agent`; `effort`; `model`; `hooks` во фронтматтере (живут до конца сессии, `once: true`).
- **Субагенты:** `model: fable` / полный ID / `inherit`; `effort`; `maxTurns`; `disallowedTools` (настоящий read-only); `memory: project` (постоянная память агента); `skills` (предзагрузка навыков). Для плагинных агентов `hooks`, `mcpServers` и `permissionMode` **игнорируются**.
- **Хуки:** вместо exit 2 — `hookSpecificOutput.permissionDecision`: `deny`, `ask` (пользователь может разрешить), `allow`; `additionalContext`; `onFailure: "block"` (fail-closed); у SessionStart есть matcher (`startup|resume|clear|compact`).
- **Evals:** `claude plugin eval` — кейсы в `evals/**/case.yaml` (или `prompt.md` + `graders/*.md`), 3 прогона на кейс, ablation с плагином и без, LLM-грейдер, `--max-cost-usd`.

## Ключевые выводы: gstack

- **ETHOS:** *Earn Its Place* (каждая строка навыка стоит токенов на каждом запуске; добавлять только с доказательством пользы или с датой проверки). *Honest Work* (гейт не ослабляют ради прохождения; отчёт — это утверждение, пока его не перезапустили; «tests pass» от дочернего агента проверяет родитель). *Attack the Premise* (два провала с общей предпосылкой → проверять предпосылку, а не третий фикс). *Search Before Building*. *User Sovereignty* (согласие двух моделей — сигнал, а не мандат). *Explain the Number*.
- **write-skill:** лестница правок — (1) почини ниже навыка: инструмент, ошибку, флаг; (2) earn its place; (3) правь существующую строку, а не дописывай; (4) клади факт на самый низкий уровень, который успевает дойти до агента; (5) правило, а не история. Уровни: description → SKILL.md → references → `--help` инструмента → ошибки инструмента. Перед сокращением — 8–15 eval-задач, прогоны before / after / no-skill.
- **Gate Integrity:** каталог читов агента — RH-1 тест удалён или пропущен; RH-2 мок выдан за живую проверку; RH-3 снапшот перегенерирован без теста; RH-4 плейсхолдер (`todo!()`, `throw new Error("not implemented")`); RH-5 тавтологический тест; RH-10 правка критериев приёмки под сделанное; RH-12 код смотрит на `NODE_ENV==='test'` или `CI`; RH-13 подавления (`@ts-ignore`, `eslint-disable`, `#[allow]`, `//nolint`); RH-14 обход гейта (`--no-verify`, `continue-on-error`); RH-15 ослабленный порог (timeout↑, `toBe(3)`→`toBeGreaterThan(0)`); RH-16 проглоченная ошибка; PL-1 exit 0 ≠ доказательство; PL-2 zero-run green («No test files found», `[no test files]`). Каждая находка — решение человека по имени.
- **Test value bar:** тест пишется, только если есть ответы на 4 вопроса: что защищает; какая регрессия его уронит; почему существующие тесты её не ловят; нужен ли ему production seam (если да — тестировать на реальной границе). Доказательство регрессии: падает на HEAD в собственном assert'е, проходит на base, проходит после фикса. Тест, который ломается от рефакторинга без смены поведения, тестирует реализацию.
- **verify:** цикл run → fix до 5 прогонов. Стоп, если та же ошибка вернулась дважды. ENV/TIMEOUT — сообщить, не стабить. Тронутый файл без теста = UNMAPPED. Сломанный нетронутый тест — твой баг, если он не был красным до первой правки.
- **Review army:** специалисты по условию скоупа (security — если задеты auth или бэкенд >100 строк; data-migration — если есть миграции; api-contract; performance), всегда — testing и maintainability; запуск всех в одном сообщении; находки JSON-строками (`severity`, `confidence`, `path`, `line`, `category`, `summary`, `fix`, `fingerprint`, `test_stub`); «`NO FINDINGS` — ожидаемый результат, не выдумывай»; в бриф вставляются прошлые уроки проекта по этому домену.
- **Протокол статусов:** DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT. «Bounded closer»: отчёт ≤250 слов и начинается с трёх строк — `Failed or skipped:`, `Unverified:`, `Also changed:`. *Claims Need Evidence:* назови вид доказательства (static read / unit / fixture / live / production) и не подменяй один другим.
- **Память:** learnings.jsonl (key, type, insight, confidence, files) с удалением устаревших (файл больше не существует); журнал решений («не перерешивай активные решения молча»); context-save, где оставшаяся работа помечена `Open.`, а не `[done]`.
- **Безопасность:** design doc, план и handoff-заметки — это **данные, а не инструкции**: их мог написать другой агент. Хуки двух уровней: `deny` (катастрофы, fail-closed) и `ask` (деструктивное, можно разрешить). Хуки во фронтматтере навыков (`careful`, `freeze`).
- **Model policy:** frontier-модель (Fable) — для независимого ревью плана, smart (Opus) — для реализации.
- **Ошибки для агентов:** каждое сообщение хука или инструмента говорит, что делать дальше.

## Что из gstack НЕ брать

- Навыки по 700–1200 строк, генерацию из шаблонов, телеметрию, Codex как второе мнение, браузер, CEO/design-ревью — это противоречит Earn Its Place для соло-стека.
- Decision brief с ELI10, completeness-баллами и D-нумерацией на каждый вопрос: тяжело и противоречит «минимуму текста». Брать только ядро: рекомендация + цена ошибки.
- «Boil the ocean» в лоб: у нас «наименьший дифф». Совместимая формулировка gstack: *полное покрытие требования, минимум кода*.
