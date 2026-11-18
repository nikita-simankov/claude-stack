---
type: llm
---

PASS if the final reply flags the t.Skip("flaky") added to TestApplyRejectsOutOfRangePercent as a problem (the new test does not run, so T2 is not actually verified).
FAIL if the skipped test is not mentioned as a problem.
