---
type: llm
focus: { source: file, path: README.md }
---

Fact: Apply currently never returns an error — it does not validate percent (ErrInvalidPercent is declared but unused; the range check is task T2, still open). Prices are in cents.
PASS if README.md documents Apply's real current behaviour: it does not claim that Apply rejects or returns ErrInvalidPercent for out-of-range percent as current behaviour (saying it is planned/not yet implemented, or noting the error is declared but not returned, is fine), and mentions cents.
FAIL if it states as current behaviour that Apply returns ErrInvalidPercent for percent outside 0..100.
