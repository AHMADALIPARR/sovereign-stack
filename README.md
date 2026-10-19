# Sovereign Stack

AGPL-3.0-only

Production-oriented repository for the Codex micro-agent runtime and the sovereign command grammar.

## Status

**Production foundation.**

- `sovereign-cmd/` — complete zero-dependency Rust lexer, parser, and execution contract with tests
- `codex/` — Elixir DynamicSupervisor + Rust InferenceWorker with budgets, cancellation, mock backend, and grammar contracts
- CI — GitHub Actions runs `cargo test` / `cargo build` for both Rust crates and `mix compile` for the supervisor
- License — AGPL-3.0-only

Not yet a full llama.cpp production deployment (Port/NIF + constrained decoding still open), but the core contracts, supervision, and parsing are production-structured and tested.

## Layout

```
sovereign-stack/
├── .github/workflows/ci.yml
├── Makefile
├── LICENSE
├── README.md
├── sovereign-cmd/          # complete
│   ├── src/{ast,lexer,parser,contract,error,main,lib}.rs
│   ├── tests/basic.rs
│   └── grammar/commands.llama.gbnf
└── codex/
    ├── supervisor/         # Elixir/OTP
    ├── runtime/            # Rust worker
    └── grammar/            # validators
```

## Build & Test

```bash
make test
make build
```

Or individually:

```bash
cd sovereign-cmd && cargo test
cd codex/runtime && cargo test
cd codex/supervisor && mix compile
```

## Invariants covered

I1 depth · I2 fan-out · I3 terminal state · I4 stale discard · I5 invalid rejection · I8 budget/deadline · I9 parent cancel

## License

GNU Affero General Public License v3.0 or later. See [LICENSE](LICENSE).
