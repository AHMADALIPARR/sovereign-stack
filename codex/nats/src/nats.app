{application, nats, [
    {description, "Hand-rolled NATS-compatible messaging for Sovereign Stack"},
    {vsn, "0.1.0"},
    {modules, [nats_app, nats_sup, nats_server, nats_conn, nats_client, nats_frame, nats_sub, nats_queue, nats_inbox, nats_stats, nats_route]},
    {registered, [nats_sup, nats_server]},
    {applications, [kernel, stdlib]},
    {mod, {nats_app, []}},
    {env, [{port, 4222}]}
]}.
