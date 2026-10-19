# Codex — Half One Status

## Agent 1 — Supervisor / BEAM
- DynamicSupervisor tree
- Lifecycle state machine (CREATED → … → TERMINATED)
- Message envelope + Router (stale discard)
- Budget / deadline enforcement
- Admission control + backpressure
- Files: `supervisor/lib/codex/{application,supervisor,worker,router,admission}.ex`

## Agent 2 — Inference / Rust
- Worker crate with WorkerConfig / WorkerResult
- Atomic cancellation + token budget
- MockBackend (deterministic)
- Documented C ABI surface (`ffi.rs`)
- Files: `runtime/src/{main,mock,ffi}.rs`

## Agent 3 — Grammar / Verification
- Validator interface for boolean, enum, command contracts
- Rejection of malformed output (I5)
- Files: `grammar/src/validator.ex`

## Synchronization Barrier
Half One foundation is in place.  
No Python / TypeScript.  
Ownership boundaries respected.

## Next (Half Two)
- Real Port/NIF bridge
- llama.cpp constrained decoding
- Concurrent 3-worker demo + property tests
- Full invariant suite (I1–I10)

AGPL-3.0-only
