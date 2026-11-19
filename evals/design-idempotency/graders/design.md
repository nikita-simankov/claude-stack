---
type: llm
---

PASS if the reported design gives at least two genuinely different options with trade-offs and recommends recording each event ID durably with a uniqueness guarantee in Postgres (e.g. a processed_events table with a UNIQUE/primary key on event id, inserted in the same transaction as the paid_total update, or INSERT ... ON CONFLICT DO NOTHING), explaining why that beats a Redis or advisory lock alone (locks do not survive restarts/expiry and do not deduplicate retries that arrive after the lock is released).
FAIL if it recommends only a Redis/distributed lock or in-memory dedup, or gives a single option without trade-offs.
