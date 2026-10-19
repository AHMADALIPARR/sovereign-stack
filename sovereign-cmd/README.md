# sovereign-cmd

Zero-dependency Rust lexer, parser, and execution contract for the sovereign command grammar.

AGPL-3.0-only

## Build
```bash
cargo test
cargo build --release
cargo run --bin sovereign-cmd
```

## Grammar
See `grammar/commands.llama.gbnf` (llama.cpp compatible).

## Contract rules
- WRITE to memory < 0x1000 is rejected
- RUN must be a path under `/opt/sovereign/bin/`
