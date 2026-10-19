# Sovereign Stack

Offline snapshot of the sovereign command grammar stack and related experiments.
Built by copying sources only. **micro-agents is a WIP snapshot**
taken while another worker was still writing that tree.

## Components

### ternary6502/

A small ternary MLP (16→8→4 + argmax) for the NMOS 6502: hand-written ca65
assembly, Free Pascal opcode-lowering (`table` / `unrolled`), a Sovereign-style
command front-end (`cmdlower`), and a minimal cycle-counting emulator. Build /
test offline with `make all` then `make verify` (needs cc65, fpc, gcc, python3).
Measured status from its README (seed=42): asm 400 bytes / 7140 cycles (match
ref); Pascal table 403 bytes / 7146 cycles; Pascal unrolled 1871 bytes / 3051
cycles; demo.cmd+model 52+400 bytes / 7213 cycles — all bit-exact vs
`tools/ref.py`. **License: not yet specified.**

### sovereign-cmd/

Zero-dependency Rust crate (MSRV 1.70; tested with rustc 1.85.1): zero-copy
lexer, hand-written parser, and execution contract for `grammar/commands.gbnf`,
plus CLI and optional llama.cpp GBNF differential tests. Build / test offline:
`cargo test --offline` / `cargo build --release`. Status from its README:
offline `std`-only build; length-capped grammar variant; llama.cpp rejects the
verbatim `_`-named rules (use `commands.llama.gbnf`); differential corpus
(48 hand + 600 random + 400 generated, plus 24 capped boundary cases) matches
llama.cpp when a validator binary is present, otherwise the xcheck test
SKIPs and passes. **License: MIT OR Apache-2.0** (from `Cargo.toml`).

### grammar-decode/

Grammar-constrained decoding experiment for `commands.gbnf` on small-v3 (34M)
and box-200m-intent, measured 2026-10-18 20:50–21:10 PT. Scripts are the
top-level `*.py` runners; results live in `results.json`,
`validator_results.json`, and `outputs/*.jsonl`. Reproduce via
`fragmentation.py`, `run_llama.py`, `run_torch.py`, `validate.py`,
`summarize.py` (see component README). Measured highlights from its README:
unconstrained parse 0/20 both models; plain/capped GBNF parse 20/20; PyTorch
greedy matches llama.cpp on 20/20 token-id sequences; lexical-anchor sampler
drops verb fragmentation to 0/20 but raises small-v3 contract violations
1→11. **License: not yet specified.**

### micro-agents/ — WIP

Elixir umbrella-style project (Mix, no Hex deps; optional Rust NIF/port under
`rust-worker/`) for grammar/contract validation, coordinator/worker machines,
and llama.cpp HTTP bench helpers. Installation notes in its README are still
the Mix template stub (`TODO: Add description`). **This copy is a WIP
snapshot** — another worker was actively writing the source tree when the
bundle was made; do not treat it as finished. Build when ready with
`mix compile` / `mix test` (Elixir ~> 1.18). **License: not yet specified.**

### gguf-lab/

Text-only notes and small eval artifacts from `/workspace/gguf-lab-october`
(weights and datasets excluded): `pytorch-4b/TRAINING_RUN.md` (CPU small/34M
training write-up), `scripts/build_corpus_v3.py`,
`runs/small-cpu-v3/eval-*.json` + `report.json` (report: 34,018,176 params,
4648 steps, final_val_loss_full ≈ 3.22), and
`runs/box-200m-intent/STATUS.md` (SFT→EI→DPO pipeline; dpo all-acc 0.5458).
Parent project files carry **SPDX AGPL-3.0-only**; see those docs. Model
weights (`*.pt` / `*.gguf`) and datasets >5 MB stay on the box (listed below).

## Repository tree (depth 2)

```
sovereign-stack/
├── .gitignore
├── MANIFEST.md
├── README.md
├── gguf-lab/
│   ├── pytorch-4b/
│   ├── runs/
│   └── scripts/
├── grammar-decode/
│   ├── README.md
│   ├── cmd_dfa.py
│   ├── commands-capped.gbnf
│   ├── commands.gbnf
│   ├── commands.llama.gbnf
│   ├── fragmentation.json
│   ├── fragmentation.py
│   ├── logs/
│   ├── metrics.py
│   ├── outputs/
│   ├── prompts.py
│   ├── results.json
│   ├── run_llama.py
│   ├── run_torch.py
│   ├── summarize.py
│   ├── validate.py
│   └── validator_results.json
├── micro-agents/
│   ├── .formatter.exs
│   ├── .gitignore
│   ├── README.md
│   ├── bench/
│   ├── c_src/
│   ├── config/
│   ├── lib/
│   ├── mix.exs
│   ├── priv/
│   ├── rust-worker/
│   └── test/
├── sovereign-cmd/
│   ├── .gitignore
│   ├── Cargo.lock
│   ├── Cargo.toml
│   ├── README.md
│   ├── grammar/
│   ├── src/
│   ├── tests/
│   └── tools/
├── ternary6502/
│   ├── Makefile
│   ├── README.md
│   ├── asm/
│   ├── build/
│   ├── emu/
│   ├── examples/
│   ├── grammar/
│   ├── pascal/
│   └── tools/
```

## Manifest and exclusions

- Per-file path, byte size, and SHA-256: see [`MANIFEST.md`](MANIFEST.md).
- Build dirs (`target/`, `_build/`, `deps/`, `node_modules/`, `__pycache__/`),
  model weights (`*.pt`, `*.gguf`), and datasets larger than 5 MB were **not**
  copied. ternary6502 `build/*.bin` / `.prg` / `.lst` are tiny machine-code
  outputs (not model weights) and **are** included.

### Excluded large / build artifacts (on-box paths)

| Path | Bytes | Size |
|------|------:|------|
| `/workspace/gguf-lab-october/runs/box-200m-intent/box-200m-intent-dpo.gguf` | 804398048 | 767.1 MB |
| `/workspace/gguf-lab-october/runs/box-200m-intent/box-200m-intent-ei.gguf` | 804398048 | 767.1 MB |
| `/workspace/gguf-lab-october/runs/box-200m-intent/sft.pt` | 803344205 | 766.1 MB |
| `/workspace/gguf-lab-october/runs/box-200m-intent/dpo.pt` | 803344205 | 766.1 MB |
| `/workspace/gguf-lab-october/runs/box-200m-intent/ei-pre-dpo.pt` | 803344024 | 766.1 MB |
| `/workspace/gguf-lab-october/runs/box-200m-intent/ei.pt` | 803344024 | 766.1 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/v3/raw/train-00000.parquet` | 248731111 | 237.2 MB |
| `/workspace/gguf-lab-october/runs/small-cpu-v3/small-v3-final.gguf` | 137155936 | 130.8 MB |
| `/workspace/gguf-lab-october/runs/small-cpu-v3/best.pt` | 136089915 | 129.8 MB |
| `/workspace/gguf-lab-october/runs/small-cpu-v3/final.pt` | 136089914 | 129.8 MB |
| `/workspace/sovereign-cmd/target/` | 135808350 | 129.5 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/snapkitty2/corpus.jsonl` | 55252741 | 52.7 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/snapkitty/corpus.jsonl` | 54645603 | 52.1 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/snapkitty/tokens.bin` | 31396418 | 29.9 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/snapkitty2/tokens.bin` | 31365152 | 29.9 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/v4/corpus.jsonl` | 27367301 | 26.1 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/v3/tokens.bin` | 22013212 | 21.0 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/v4/tokens.bin` | 18586448 | 17.7 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/devflow-corpus.jsonl` | 14164841 | 13.5 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/tokens.bin` | 11012912 | 10.5 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/v3/raw/validation.parquet` | 9989127 | 9.5 MB |
| `/workspace/gguf-lab-october/pytorch-4b/data/re-corpus.jsonl` | 6982724 | 6.7 MB |
| `/workspace/gguf-lab-october/pytorch-4b/dss/host/target/release/deps/libsyn-5768df391851bdf0.rlib` | 6016348 | 5.7 MB |
| `/workspace/micro-agents/_build/` | 713896 | 697.2 KB |
| `/workspace/grammar-decode/__pycache__/` | 11650 | 11.4 KB |

## Top-level `.gitignore`

Ignores `target/`, `_build/`, `deps/`, `node_modules/`, `*.gguf`, `*.pt`,
`__pycache__/`, `*.pyc`, `.DS_Store`.

## License note

Licenses were taken only from each component's own README / metadata:

| Component | License |
|-----------|---------|
| ternary6502 | not yet specified |
| sovereign-cmd | MIT OR Apache-2.0 (`Cargo.toml`) |
| grammar-decode | not yet specified |
| micro-agents | not yet specified |
| gguf-lab (copied notes) | AGPL-3.0-only (SPDX in source docs); parent also has COMMERCIAL.md |

Where none was stated, this bundle records **License: not yet specified** rather
than choosing one.

---

Full source package is available on the Grok Bots shared computer at `/workspace/sovereign-stack-src/` and `/workspace/sovereign-stack-src.zip`. The Grok Bot can push the complete tree if GitHub access is authorized on its computer.
