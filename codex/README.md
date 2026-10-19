# Codex Master Contract — Complete Half One + Integration Scaffold

AGPL-3.0-only

## What is implemented
- Elixir DynamicSupervisor + Worker lifecycle (CREATED → TERMINATED)
- Admission control, depth limit, deadline, cancellation
- Message envelope + stale discard
- Rust InferenceWorker with atomic cancel, token budget, MockBackend
- Documented llama.cpp C ABI surface
- Grammar Validator (boolean / enum / command contracts)
- 3-worker demo entry point

## Invariants addressed
I1 depth, I2 fan-out, I3 terminal state, I4 stale discard, I5 invalid rejection, I8 budget/deadline, I9 parent cancel.

## Build & run
```bash
cd supervisor && mix compile
cd ../runtime && cargo build --release && cargo run --bin codex-worker
```



