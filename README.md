# Sovereign Stack

![Codex micro-agent runtime](assets/header.jpg)

**AGPL-3.0-only** · Production foundation · CI green

Three-agent recursive micro-agent runtime and sovereign command grammar.

## What this is

Isolated, bounded, short-lived inference workers under an Elixir/OTP supervisor.
Rust runtime for execution. Deterministic grammar contracts. No Python. No TypeScript.

## Status

**v1.0.0 production foundation** — CI passing on `main`.

| Component | Language | State |
|-----------|----------|-------|
| `sovereign-cmd/` | Rust | Complete lexer, parser, contract, tests |
| `codex/supervisor/` | Elixir/OTP | DynamicSupervisor, admission, lifecycle, cancel |
| `codex/runtime/` | Rust | InferenceWorker, budgets, cancellation, mock backend |
| `codex/grammar/` | Elixir | Boolean / enum / command validators |
| CI | GitHub Actions | Rust test+build, Elixir compile |

Open for later: live llama.cpp Port/NIF and constrained decoding.

## Layout

```
sovereign-stack/
├── assets/header.jpg
├── .github/workflows/ci.yml
├── Makefile
├── LICENSE
├── sovereign-cmd/
│   ├── src/
│   ├── tests/
│   └── grammar/commands.llama.gbnf
└── codex/
    ├── supervisor/
    ├── runtime/
    └── grammar/
```

## Build

```bash
make test
make build
```

## Invariants

I1 depth · I2 fan-out · I3 terminal state · I4 stale discard · I5 invalid rejection · I8 budget/deadline · I9 parent cancel

## License

GNU Affero General Public License v3.0 or later. See [LICENSE](LICENSE).
