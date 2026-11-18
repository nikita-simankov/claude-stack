---
type: llm
focus: { source: file, path: docs/specs/coupons/tasks.md }
---

Context: the spec superseded AC3 (expired coupon → 0) with AC5 (expired coupon → price after the percent discount, ErrCouponExpired). Task T1 was already done.
PASS if T1 is still marked done and unchanged in meaning, the old AC3 task is no longer an open task with the old expectation (it is removed, marked superseded, or rewritten for AC5), and a task covers AC5 with a concrete test case (1000, 10%, expired coupon 100 → 900, ErrCouponExpired).
FAIL if the old expectation "expired → 0" is still an open task, AC5 has no concrete test case, or T1 was unticked or rewritten.
