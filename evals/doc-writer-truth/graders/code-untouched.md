---
type: regex
arm: both
target: { source: file, path: pricing/discount.go }
pattern: "return price - price\\*int64\\(percent\\)/100, nil\\n\\}"
---
