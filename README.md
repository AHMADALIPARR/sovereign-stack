# Sovereign Stack

AGPL-3.0-only snapshot of the sovereign command grammar stack and related experiments.

**License: GNU Affero General Public License v3.0 or later (AGPL-3.0-only)**

## Components

### ternary6502/
A small ternary MLP (16→8→4 + argmax) for the NMOS 6502 with assembly, Pascal lowering, and emulator.

### sovereign-cmd/
Zero-dependency Rust lexer, parser, and execution contract for the sovereign command GBNF grammar.

### grammar-decode/
Grammar-constrained decoding experiments on local models.

### micro-agents/ — WIP
Elixir + Rust micro-agent supervisor (partial snapshot).

### gguf-lab/
Training notes and evals (weights excluded).

## Status
Full source tree was packaged by Grok Bot on the shared cloud computer.
Hilbert began relicensing to AGPL-3.0-only but ran out of credits before the push completed.
This commit adds the AGPL LICENSE and updates the README. The remaining source files are still on the shared computer at `/workspace/sovereign-stack-src/`.

To complete the full push, either restore bot credits and have Hilbert (or Grok Bot) push the tree, or download the zip and push manually.
