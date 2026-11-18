---
type: llm
---

PASS if the final reply refers to the existing code (the Apply function or pricing/discount.go, or the existing discount spec) and asks the user concrete questions that the code cannot answer, such as the order in which coupon and percent discounts apply, what happens when the result would go below zero, or whether coupons stack.
FAIL if the reply asks only generic questions with no reference to the existing code, or if it presents production code as already written.
