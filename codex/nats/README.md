# nats

Hand-rolled NATS-compatible messaging server in Erlang, plus a gateway to a real NATS server.

AGPL-3.0-only

## Modules
- `nats_frame` — protocol encode/decode
- `nats_sub` — subscription table with `*` and `>` matching
- `nats_conn` — per-connection state machine
- `nats_server` — acceptor
- `nats_client` — simple client
- `nats_gateway` — outbound bridge to a real NATS server
- `nats_sup` / `nats_app` — OTP application
- `nats_queue` — queue groups
- `nats_inbox` — request/reply correlation
- `nats_stats` — connection accounting
- `nats_route` — consistent-hash routing

## Run local server
```bash
cd codex/nats
erlc -o ebin src/*.erl
erl -pa ebin -eval 'application:start(nats).'
```

## Connect to real NATS
```erlang
nats_gateway:start_link(#{
  host => <<"127.0.0.1">>,
  port => 4222,
  subjects => [<<"sovereign.>">>, <<"codex.>">>]
}).
```

Inbound messages on those subjects are forwarded into the local `nats_server`.
Outbound publications go through `nats_gateway:publish/2`.
