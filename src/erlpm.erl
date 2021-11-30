%%% @doc external alias for `epm_agent' for more convenient
%%% calls from a shell.
-module(erlpm).
-export([
    do/1, do/2, do/3, async_do/1, async_do/2, async_do/3, break/0, resume/0
    , '$handle_undefined_function'/2
]).

-include("epm.hrl").

%% @doc alias for `epm_agent:do/1'
-spec do(atom() | string()) -> ok | {error, term()}.
do(Command) -> epm_agent:do(Command).

%% @doc alias for `epm_agent:do/2'
-spec do(atom(), atom() | string()) -> ok | {error, term()}.
do(Namespace, Command) -> epm_agent:do(Namespace, Command).

%% @doc alias for `epm_agent:do/3'
-spec do(atom(), atom(), string()) -> ok | {error, term()}.
do(Namespace, Command, Args) -> epm_agent:do(Namespace, Command, Args).

%% @doc alias for `epm_agent:async_do/1'
-spec async_do(atom()) -> ok.
async_do(Command) -> epm_agent:async_do(Command).

%% @doc alias for `epm_agent:async_do/2'
-spec async_do(atom(), atom()) -> ok.
async_do(Namespace, Command) -> epm_agent:async_do(Namespace, Command).

%% @doc alias for `epm_agent:async_do/3'
-spec async_do(atom(), atom(), string()) -> ok.
async_do(Namespace, Command, Args) -> epm_agent:async_do(Namespace, Command, Args).

break() ->
    case whereis(epm_agent) of % is the shell running
        undefined ->
            ok;
        Pid ->
            {dictionary, Dict} = process_info(Pid, dictionary),
            case lists:keyfind(cmd_type, 1, Dict) of
                {cmd_type, async} ->
                    Self = self(),
                    Ref = make_ref(),
                    spawn_link(fun
                                   () ->
                                       register(r3_breakpoint_handler, self()),
                                       receive
                                           resume ->
                                               Self ! Ref
                                       end
                               end),
                    io:format(user, "~n=== BREAK ===~n", []),
                    receive
                        Ref -> ok
                    end;
                _ ->
                    ?DEBUG("ignoring breakpoint since command is not run "
                    "in async mode", []),
                    ok
            end
    end.

resume() ->
    r3_breakpoint_handler ! resume,
    ok.

%% @private defer to epm_agent
'$handle_undefined_function'(Cmd, Args) ->
    epm_agent:'$handle_undefined_function'(Cmd, Args).
