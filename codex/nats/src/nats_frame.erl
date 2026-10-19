%% SnapKitty Opaque License
%% Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
%% Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md
%%
%% Hand-rolled NATS protocol constants and frame helpers.
-module(nats_frame).
-export([
    encode_info/1,
    encode_msg/5,
    encode_ok/0,
    encode_err/1,
    encode_ping/0,
    encode_pong/0,
    parse_line/1,
    split_frames/1
]).

-define(CRLF, <<"\r\n">>).

encode_info(Info) when is_map(Info) ->
    Json = jsx_like(Info),
    <<"INFO ", Json/binary, ?CRLF/binary>>.

encode_msg(Subject, Sid, ReplyTo, Headers, Payload) ->
    ReplyPart =
        case ReplyTo of
            undefined -> <<>>;
            R when is_binary(R) -> <<" ", R/binary>>
        end,
    HdrPart =
        case Headers of
            undefined -> <<>>;
            H when is_binary(H) -> <<" ", H/binary>>
        end,
    Size = integer_to_binary(byte_size(Payload)),
    <<"MSG ", Subject/binary, " ", Sid/binary, ReplyPart/binary, HdrPart/binary,
      " ", Size/binary, ?CRLF/binary, Payload/binary, ?CRLF/binary>>.

encode_ok() -> <<"OK", ?CRLF/binary>>.
encode_err(Reason) when is_binary(Reason) ->
    <<"-ERR ", Reason/binary, ?CRLF/binary>>.
encode_ping() -> <<"PING", ?CRLF/binary>>.
encode_pong() -> <<"PONG", ?CRLF/binary>>.

parse_line(<<"INFO ", Rest/binary>>) ->
    {info, Rest};
parse_line(<<"CONNECT ", Rest/binary>>) ->
    {connect, Rest};
parse_line(<<"PUB ", Rest/binary>>) ->
    {pub, Rest};
parse_line(<<"HPUB ", Rest/binary>>) ->
    {hpub, Rest};
parse_line(<<"SUB ", Rest/binary>>) ->
    {sub, Rest};
parse_line(<<"UNSUB ", Rest/binary>>) ->
    {unsub, Rest};
parse_line(<<"MSG ", Rest/binary>>) ->
    {msg, Rest};
parse_line(<<"PING">>) ->
    ping;
parse_line(<<"PONG">>) ->
    pong;
parse_line(<<"OK">>) ->
    ok;
parse_line(<<"-ERR ", Rest/binary>>) ->
    {err, Rest};
parse_line(Other) ->
    {unknown, Other}.

split_frames(Bin) ->
    split_frames(Bin, []).

split_frames(<<>>, Acc) ->
    {lists:reverse(Acc), <<>>};
split_frames(Bin, Acc) ->
    case binary:split(Bin, ?CRLF) of
        [Line, Rest] ->
            split_frames(Rest, [Line | Acc]);
        [Incomplete] ->
            {lists:reverse(Acc), Incomplete}
    end.

jsx_like(Map) ->
    Parts = maps:fold(
        fun(K, V, Acc) ->
            Key = atom_or_bin(K),
            Val = value_to_bin(V),
            [<<Key/binary, ":", Val/binary>> | Acc]
        end,
        [],
        Map
    ),
    Body = iolist_to_binary(lists:join(<<",">>, lists:reverse(Parts))),
    <<"{", Body/binary, "}">>.

atom_or_bin(A) when is_atom(A) -> atom_to_binary(A, utf8);
atom_or_bin(B) when is_binary(B) -> B.

value_to_bin(true) -> <<"true">>;
value_to_bin(false) -> <<"false">>;
value_to_bin(N) when is_integer(N) -> integer_to_binary(N);
value_to_bin(B) when is_binary(B) -> <<"\"", B/binary, "\"">>;
value_to_bin(A) when is_atom(A) -> <<"\"", (atom_to_binary(A, utf8))/binary, "\"">>.
