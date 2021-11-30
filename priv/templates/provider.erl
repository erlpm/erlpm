-module({{name}}_prv).

-export([init/1, do/1, format_error/1]).

-define(PROVIDER, {{name}}).
-define(DEPS, [app_discovery]).

%% ===================================================================
%% Public API
%% ===================================================================
-spec init(epm_state:t()) -> {ok, epm_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, ?PROVIDER},            % The 'user friendly' name of the task
            {module, ?MODULE},            % The module implementation of the task
            {bare, true},                 % The task can be run by the user, always true
            {deps, ?DEPS},                % The list of dependencies
            {example, "epm {{name}}"}, % How to use the plugin
            {opts, []},                   % list of options understood by the plugin
            {short_desc, "{{desc}}"},
            {desc, "{{desc}}"}
    ]),
    {ok, epm_state:add_provider(State, Provider)}.


-spec do(epm_state:t()) -> {ok, epm_state:t()} | {error, string()}.
do(State) ->
    {ok, State}.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
