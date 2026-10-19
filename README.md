# Sovereign Stack

AGPL-3.0-only

Private repository for the Codex micro-agent runtime and sovereign command grammar work.

## Repository Layout

```
sovereign-stack/
├── LICENSE
├── README.md
├── codex/
│   ├── README.md
│   ├── docs/HALF_ONE.md
│   ├── supervisor/          # Elixir/OTP
│   │   ├── mix.exs
│   │   └── lib/codex/
│   │       ├── application.ex
│   │       ├── supervisor.ex
│   │       ├── worker.ex
│   │       ├── admission.ex
│   │       ├── router.ex
│   │       └── demo.ex
│   ├── runtime/             # Rust
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── main.rs
│   │       ├── mock.rs
│   │       └── ffi.rs
│   └── grammar/             # Validation contracts
│       └── src/validator.ex
└── sovereign-cmd/          # Partial
    ├── Cargo.toml
    └── grammar/commands.llama.gbnf
```

## `codex/` — Half One Scaffold

Compilable foundation for the Codex Master Contract.

| Component | Language | Status |
|-----------|----------|--------|
| Supervisor | Elixir/OTP | DynamicSupervisor, lifecycle, admission, depth limit, deadline, cancel |
| Inference | Rust | InferenceWorker, atomic cancel, token budget, MockBackend, C ABI surface |
| Grammar | Elixir | boolean / enum / command validators |
| Demo | Elixir | 3-worker concurrent spawn + cancel |

### Invariants present in code
- I1 — recursion depth bounded
- I2 — fan-out / active count bounded
- I3 — worker reaches one terminal state
- I4 — stale messages discarded
- I5 — invalid output rejected
- I8 — finite deadline and token budget
- I9 — parent can cancel children

## Status

**Not production.**

Half One foundation is present and structured. Half Two is not started:
- Port/NIF bridge Elixir ↔ Rust
- Real llama.cpp integration and constrained decoding
- Property tests and failure injection
- Measured benchmarks (p50/p95/p99)
- Full I1–I10 suite

The original Grok Bot package (`ternary6502/`, full `sovereign-cmd/src/`, `grammar-decode/`, earlier `micro-agents/`) remains only on the bots’ shared computer and is not in this repository.

## Build

```bash
cd codex/supervisor && mix compile
cd ../runtime && cargo build --release && cargo run --bin codex-worker
```

## License

GNU Affero General Public License v3.0 or later (AGPL-3.0-only).  
See [LICENSE](LICENSE).
