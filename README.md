# Sovereign Stack

AGPL-3.0-only

Private repository containing the Codex micro-agent runtime and related sovereign command grammar experiments.

## Current Contents

### `codex/` — Active development
Working Half One scaffold for the Codex Master Contract (three-agent recursive micro-agent runtime).

- **Supervisor (Elixir/OTP)** — `codex/supervisor/`
  - DynamicSupervisor for ephemeral workers
  - Lifecycle: CREATED → ADMITTED → RUNNING → VALIDATING → COMPLETED → TERMINATED
  - Admission control, recursion depth limit, deadline, cancellation, stale-message discard
  - 3-worker demo entry point

- **Inference runtime (Rust)** — `codex/runtime/`
  - InferenceWorker with atomic cancellation and token budget
  - Deterministic MockBackend
  - Documented C ABI surface for future llama.cpp integration

- **Grammar / Verification** — `codex/grammar/`
  - Validator for boolean, enum, and command contracts
  - Invalid output is rejected before it can reach the approved channel

Invariants currently addressed in code: I1 (depth), I2 (fan-out), I3 (terminal state), I4 (stale discard), I5 (invalid rejection), I8 (budget/deadline), I9 (parent cancel).

### `sovereign-cmd/`
Partial. Only `Cargo.toml` and `grammar/commands.llama.gbnf` are present. The full Rust lexer/parser/contract sources were not pushed.

### Missing from this repository
The following still exist only on the Grok Bots shared computer (`/workspace/sovereign-stack-src/`):
- Full `ternary6502/` (6502 ternary model + Pascal lowering + emulator)
- Complete `sovereign-cmd/src/` tree
- `grammar-decode/` experiment scripts and results
- Earlier `micro-agents/` WIP snapshot

## Status
**Not production.**

This is a compilable foundation that matches the Codex Master Contract Half One deliverables. Half Two work remains:
- Real Port/NIF bridge between Elixir and Rust
- llama.cpp constrained decoding
- Property tests and measured benchmarks
- Full I1–I10 invariant suite

## Build
```bash
# Elixir supervisor
cd codex/supervisor && mix compile

# Rust runtime
cd ../runtime && cargo build --release && cargo run --bin codex-worker
```

## License
GNU Affero General Public License v3.0 or later (AGPL-3.0-only).
See `LICENSE`.
