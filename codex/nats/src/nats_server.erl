%% NATS server acceptor. Listens and spawns nats_conn processes.
-module(nats_server).
-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-export([publish/3, stats/0]).

-record(state, {
    listen_sock,
    port,
    conns = [],
    subs,
    started_at
}).

start_link(Port) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

init([Port]) ->
    Opts = [binary, {packet, 0}, {active, false}, {reuseaddr, true}],
    {ok, LSock} = gen_tcp:listen(Port, Opts),
    self() ! accept,
    {ok, #state{
        listen_sock = LSock,
        port = Port,
        subs = nats_sub:new(),
        started_at = erlang:system_time(second)
    }}.

handle_call({publish, Subject, Payload}, _From, State) ->
    deliver_all(State, Subject, Payload),
    {reply, ok, State};
handle_call(stats, _From, State) ->
    {reply, #{
        port => State#state.port,
        connections => length(State#state.conns),
        subscriptions => nats_sub:count(State#state.subs),
        uptime => erlang:system_time(second) - State#state.started_at
    }, State};
handle_call(_Req, _From, State) ->
    {reply, {error, bad_call}, State}.

handle_cast({register_conn, Pid}, State) ->
    {noreply, State#state{conns = [Pid | State#state.conns]}};
handle_cast({unregister_conn, Pid}, State) ->
    {noreply, State#state{conns = lists:delete(Pid, State#state.conns)}};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(accept, #state{listen_sock = LSock} = State) ->
    case gen_tcp:accept(LSock, 100) of
        {ok, Sock} ->
            {ok, Pid} = nats_conn:start_link(Sock, self()),
            gen_tcp:controlling_process(Sock, Pid),
            inet:setopts(Sock, [{active, once}]),
            gen_server:cast(?MODULE, {register_conn, Pid}),
            self() ! accept,
            {noreply, State};
        {error, timeout} ->
            self() ! accept,
            {noreply, State};
        {error, closed} ->
            {stop, normal, State}
    end;
handle_info({nats_conn_down, Pid}, State) ->
    {noreply, State#state{conns = lists:delete(Pid, State#state.conns)}};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{listen_sock = LSock}) ->
    catch gen_tcp:close(LSock),
    ok.

publish(Subject, Payload) ->
    gen_server:call(?MODULE, {publish, Subject, Payload}).

stats() ->
    gen_server:call(?MODULE, stats).

deliver_all(#state{conns = Conns}, Subject, Payload) ->
    lists:foreach(
        fun(Pid) ->
            catch gen_server:call(Pid, {publish, Subject, undefined, Payload}, 100)
        end,
        Conns
    ),
    ok.
