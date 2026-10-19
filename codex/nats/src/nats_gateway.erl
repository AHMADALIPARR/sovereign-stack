%% SnapKitty Opaque License
%% Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
%% Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md
%%
%% Gateway that bridges the local hand-rolled NATS to a real NATS server.
%% Connects outbound, subscribes to configured subjects, and forwards
%% publications in both directions.
-module(nats_gateway).
-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-export([publish/2, subscribe/1, status/0]).

-record(state, {
    socket,
    host,
    port,
    buffer = <<>>,
    subjects = [],
    connected = false,
    info = #{}
}).

%% Start with #{host => <<"127.0.0.1">>, port => 4222, subjects => [<<"sovereign.>">>]}
start_link(Opts) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Opts], []).

init([Opts]) ->
    Host = maps:get(host, Opts, <<"127.0.0.1">>),
    Port = maps:get(port, Opts, 4222),
    Subjects = maps:get(subjects, Opts, [<<"sovereign.>">>]),
    case gen_tcp:connect(binary_to_list(Host), Port, [binary, {packet, 0}, {active, once}], 5000) of
        {ok, Sock} ->
            {ok, #state{socket = Sock, host = Host, port = Port, subjects = Subjects}};
        {error, Reason} ->
            {stop, {connect_failed, Reason}}
    end.

handle_call({publish, Subject, Payload}, _From, #state{connected = true} = State) ->
    Size = integer_to_binary(byte_size(Payload)),
    Frame = <<"PUB ", Subject/binary, " ", Size/binary, "\r\n", Payload/binary, "\r\n">>,
    ok = gen_tcp:send(State#state.socket, Frame),
    {reply, ok, State};
handle_call({publish, _, _}, _From, State) ->
    {reply, {error, not_connected}, State};
handle_call({subscribe, Subject}, _From, #state{connected = true, subjects = Subs} = State) ->
    Sid = integer_to_binary(erlang:unique_integer([positive])),
    Frame = <<"SUB ", Subject/binary, " ", Sid/binary, "\r\n">>,
    ok = gen_tcp:send(State#state.socket, Frame),
    {reply, ok, State#state{subjects = [Subject | Subs]}};
handle_call(status, _From, State) ->
    {reply, #{
        connected => State#state.connected,
        host => State#state.host,
        port => State#state.port,
        subjects => State#state.subjects,
        info => State#state.info
    }, State};
handle_call(_Req, _From, State) ->
    {reply, {error, bad_call}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, Sock, Data}, #state{socket = Sock, buffer = Buf} = State) ->
    Combined = <<Buf/binary, Data/binary>>,
    {Lines, Rest} = nats_frame:split_frames(Combined),
    NewState = lists:foldl(fun on_line/2, State#state{buffer = Rest}, Lines),
    inet:setopts(Sock, [{active, once}]),
    {noreply, NewState};
handle_info({tcp_closed, _}, State) ->
    {stop, normal, State#state{connected = false}};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{socket = Sock}) ->
    catch gen_tcp:close(Sock),
    ok.

publish(Subject, Payload) ->
    gen_server:call(?MODULE, {publish, Subject, Payload}).

subscribe(Subject) ->
    gen_server:call(?MODULE, {subscribe, Subject}).

status() ->
    gen_server:call(?MODULE, status).

on_line(<<"INFO ", Rest/binary>>, State) ->
    Info = #{raw => Rest},
    Connect = <<"CONNECT {\"verbose\":false,\"pedantic\":false,\"lang\":\"erlang\",\"version\":\"0.1.0\"}\r\n">>,
    gen_tcp:send(State#state.socket, Connect),
    lists:foreach(
        fun(Subj) ->
            Sid = integer_to_binary(erlang:unique_integer([positive])),
            Frame = <<"SUB ", Subj/binary, " ", Sid/binary, "\r\n">>,
            gen_tcp:send(State#state.socket, Frame)
        end,
        State#state.subjects
    ),
    State#state{connected = true, info = Info};
on_line(<<"PING">>, State) ->
    gen_tcp:send(State#state.socket, nats_frame:encode_pong()),
    State;
on_line(<<"MSG ", Rest/binary>>, State) ->
    case binary:split(Rest, <<" ">>, [global]) of
        [Subject, _Sid, _SizeBin] ->
            catch nats_server:publish(Subject, <<>>),
            State;
        [Subject, _Sid, _Reply, _SizeBin] ->
            catch nats_server:publish(Subject, <<>>),
            State;
        _ ->
            State
    end;
on_line(<<"OK">>, State) ->
    State;
on_line(<<"PONG">>, State) ->
    State;
on_line(<<"-ERR ", Reason/binary>>, State) ->
    error_logger:error_msg("nats gateway err: ~s~n", [Reason]),
    State;
on_line(_, State) ->
    State.
