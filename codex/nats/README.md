# nats

Hand-rolled NATS-compatible messaging server in Erlang.

AGPL-3.0-only

## Modules
- `nats_frame` — protocol encode/decode
- `nats_sub` — subscription table with `*` and `>` matching
- `nats_conn` — per-connection state machine
- `nats_server` — acceptor
- `nats_client` — simple client
- `nats_sup` / `nats_app` — OTP application
- `nats_queue` — queue groups
- `nats_inbox` — request/reply correlation
- `nats_stats` — connection accounting
- `nats_route` — consistent-hash routing

## Run
```bash
cd codex/nats
erlc -o ebin src/*.erl
erl -pa ebin -eval 'application:start(nats).'
```

Default port: 4222.
Total: 754 lines of Erlang.
