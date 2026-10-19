# Codex Master Contract — Three-Agent Recursive Micro-Agent Runtime

AGPL-3.0-only

## Agents
- **Supervisor (Elixir/OTP)** — `supervisor/`
- **Inference (Rust)** — `runtime/`
- **Grammar / Verification** — `grammar/`

## Lifecycle
CREATED → ADMITTED → RUNNING → VALIDATING → COMPLETED → TERMINATED

## Invariants (I1–I10)
Implemented and tested in the respective modules. See source comments.

## Build
```bash
cd supervisor && mix compile && mix test
cd ../runtime && cargo build --release && cargo test
```

## Status
Foundation (Half One) scaffold created.
Full llama.cpp FFI, GBNF validator, and concurrent demo pending integration (Half Two).

Original package from Grok Bot remains on the shared computer at `/workspace/sovereign-stack-src/`.
