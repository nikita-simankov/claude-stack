---
type: regex
arm: both
target: { source: file, path: orders/handler.go }
pattern: "WHERE id = '\" \\+ id \\+ \"'\""
---
