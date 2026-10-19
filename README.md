# Sovereign Stack

This repository holds the sovereign command grammar, 6502 ternary model, Rust parser/contract guard, grammar-constrained decoding experiments, and micro-agent supervisor (Elixir + Rust).

## Current Status

The full source package was prepared by the Grok Bot and lives on the shared cloud computer used by Grok Bots:

- Unpacked: `/workspace/sovereign-stack-src/`
- Zip: `/workspace/sovereign-stack-src.zip` (924 KB, 191 files)

Components:
- `sovereign-cmd/`: Rust lexer, parser, AST, contract guard, GBNF grammars (all tests passed)
- `ternary6502/`: 6502 ternary model with Pascal lowering and emulator
- `grammar-decode/`: Experiments with constrained decoding on local models (box-200m-intent, small-cpu-v3)
- `micro-agents/`: Elixir supervisor + Rust worker (work in progress)
- `gguf-lab/`: Training notes and evals (weights not included)

**Note:** micro-agents is a partial snapshot. Licenses are mixed (see bot notes). Model weights/GGUFs are excluded due to size.

The Grok Bot can push the full contents if GitHub credentials are provided on its computer. This README is a placeholder until the sources are committed.

Generated and managed with assistance from Grok.
