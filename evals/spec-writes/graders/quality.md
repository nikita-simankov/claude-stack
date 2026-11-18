---
type: llm
focus: { source: file, path: docs/specs/coupons/spec.md }
---

PASS if the spec states that coupons apply after the percent discount, that the result floors at 0, one coupon per order, expired coupons fail with ErrCouponExpired, lists storage and UI as out of scope, and its acceptance criteria are concrete and testable (inputs and expected outputs or Given/When/Then).
FAIL if any of these decisions is missing or contradicted, if acceptance criteria are vague, or if the spec adds requirements the user did not ask for as if they were decided.
