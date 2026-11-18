# Rust

## Errors
- Libraries/domain: `thiserror` enums. Binaries/glue: `anyhow` with `.context("…")`.
- No `unwrap()`/`expect()` in non-test code unless the invariant is proven and commented.
- `?` everywhere; map to transport errors (axum `IntoResponse`, `tonic::Status`) at the edge only.

## Async (tokio)
- Never block the runtime: `spawn_blocking` for CPU/blocking I/O.
- Cancellation-safe `select!` branches; structured tasks with `JoinSet`.
- Shared state: prefer message passing; `Arc<Mutex>` only for small critical sections; never hold a std `Mutex` guard across `.await`.

## Design
- Make invalid states unrepresentable: newtypes for IDs, enums over boolean flags.
- Borrow in function parameters (`&str`, `&[T]`), own in structs.
- `sqlx` with compile-time checked queries if the project uses it; otherwise follow the project's DB layer.

## Testing
- Unit tests in `#[cfg(test)] mod tests` beside the code; integration tests in `tests/`.
- `#[tokio::test]` for async. `cargo clippy -- -D warnings` must pass.

```rust
#[tokio::test]
async fn upgrade_rejects_unknown_plan() {
    let svc = test_service().await;
    let err = svc.upgrade(USER_ID, "nope").await.unwrap_err();
    assert!(matches!(err, BillingError::PlanNotFound(_)));
}
```
