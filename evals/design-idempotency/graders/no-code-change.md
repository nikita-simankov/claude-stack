---
type: regex
arm: both
target: { source: file, path: payments/webhook.go }
pattern: "paid_total = paid_total \\+ \\$1 WHERE id = \\$2"
---
