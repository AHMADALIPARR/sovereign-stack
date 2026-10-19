%% SnapKitty Opaque License
%% Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
%% Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md
%%
%% Subscription table. Subject matching with * and > wildcards.
-module(nats_sub).
-export([
    new/0,
    subscribe/4,
    unsubscribe/2,
    unsubscribe_all/2,
    match/2,
    count/1,
    subjects/1
]).

-record(sub, {
    sid :: binary(),
    subject :: binary(),
    queue :: binary() | undefined,
    pid :: pid()
}).

new() ->
    #{subs => [], next => 1}.

subscribe(State, Subject, Sid, Pid) ->
    subscribe(State, Subject, Sid, undefined, Pid).

subscribe(#{subs := Subs} = State, Subject, Sid, Queue, Pid) ->
    Entry = #sub{sid = Sid, subject = Subject, queue = Queue, pid = Pid},
    State#{subs => [Entry | Subs]}.

unsubscribe(#{subs := Subs} = State, Sid) ->
    State#{subs => [S || S <- Subs, S#sub.sid =/= Sid]}.

unsubscribe_all(#{subs := Subs} = State, Pid) ->
    State#{subs => [S || S <- Subs, S#sub.pid =/= Pid]}.

match(#{subs := Subs}, Subject) ->
    lists:filter(fun(#sub{subject = Pat}) -> subject_match(Pat, Subject) end, Subs).

count(#{subs := Subs}) ->
    length(Subs).

subjects(#{subs := Subs}) ->
    lists:usort([S#sub.subject || S <- Subs]).

subject_match(Pat, Subj) ->
    P = binary:split(Pat, <<".">>, [global]),
    S = binary:split(Subj, <<".">>, [global]),
    match_tokens(P, S).

match_tokens([], []) ->
    true;
match_tokens([<<">">>], _) ->
    true;
match_tokens([<<"*">> | PT], [_ | ST]) ->
    match_tokens(PT, ST);
match_tokens([T | PT], [T | ST]) ->
    match_tokens(PT, ST);
match_tokens(_, _) ->
    false.
