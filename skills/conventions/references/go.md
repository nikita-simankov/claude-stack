# Go

## Structure
- `cmd/<svc>/main.go` wires dependencies; logic in `internal/`. Small interfaces defined by the consumer.
- Constructors take dependencies explicitly; no package-level mutable globals.

## Errors
- Wrap with context: `fmt.Errorf("load user %d: %w", id, err)`. Check with `errors.Is/As`.
- Sentinel or typed errors for conditions callers branch on. Never `panic` for expected failures.
- Log *or* return an error, not both.

## Context & concurrency
- `ctx context.Context` is the first parameter of anything doing I/O; respect cancellation.
- Every goroutine has an owner and a way to stop (`errgroup.WithContext`). No unbounded goroutine spawning.
- Run tests with `-race`.

## gRPC
- Proto in `proto/` managed by `buf`; generated code is never hand-edited.
- Map domain errors to `status.Error(codes.X, msg)` at the handler edge only.
- Deadlines on every outbound call.

## Testing
- Table-driven tests with `t.Run(tc.name, …)`; `t.Parallel()` where safe.
- Prefer real Postgres/Redis via testcontainers or compose over mocks for repository code.
- Helpers call `t.Helper()`. Use `cmp.Diff` for struct comparison.

```go
func TestUpgrade(t *testing.T) {
	tests := []struct {
		name    string
		planID  string
		wantErr error
	}{
		{"unknown plan", "nope", ErrPlanNotFound},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			_, err := svc.Upgrade(ctx, userID, tc.planID)
			if !errors.Is(err, tc.wantErr) {
				t.Fatalf("got %v, want %v", err, tc.wantErr)
			}
		})
	}
}
```
